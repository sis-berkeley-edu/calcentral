module Memcached
  require 'net/telnet'
  extend self

  def servers
    result = []
    hosts = ENV['hosts']
    if hosts.blank?
      config = CalcentralConfig.load_settings
      if config && config.cache && config.cache.servers
        hosts = config.cache.servers
      end
    else
      hosts = hosts.split ','
    end
    hosts.each do |host|
      host_tuple = host.split(':')
      hostname = host_tuple.first
      port = host_tuple[1] if host_tuple.size > 1
      port ||= 11211
      result << {
        host: hostname,
        port: port
      }
    end
    result
  end

  def send(server, command, response_over='END')
    hostname = server[:host]
    port = server[:port]
    parsed = nil
    connected_host = Net::Telnet::new('Host' => hostname, 'Port' => port, 'Telnetmode' => false, 'Timeout' => 3)
    connected_host.cmd('String' => command, 'Match' => /^#{response_over}/) do |c|
      parsed = c.split(/\r?\n/)
      parsed.slice!(-1)
    end
    connected_host.close
    parsed
  end

  def exception_message(server_id, e)
    basic_message = "ERROR: Unable to connect to #{server_id} - #{e}"
    Rails.logger.error basic_message + e.backtrace.join("\n ")
    basic_message
  end

  def all_stats
    summary = {}
    by_slabs = {}
    servers.map do |server|
      server_id = "#{server[:host]}:#{server[:port]}"
      begin
        summary[server_id] = general_stats server
        by_slabs[server_id] = slab_stats server
      rescue => e
        return exception_message(server_id, e)
      end
    end
    {
      summary: summary,
      by_slabs: by_slabs
    }
  end

  def clear_all
    summary = {}
    servers.map do |server|
      server_id = "#{server[:host]}:#{server[:port]}"
      begin
        send(server, 'flush_all', 'OK')
        send(server, 'stats reset', 'RESET')
        summary[server_id] = 'Cache invalidated and stats reset'
      rescue => e
        return exception_message(server_id, e)
      end
      summary
    end
  end

  def dump_slab_on_all(slab)
    summary = {}
    servers.map do |server|
      server_id = "#{server[:host]}:#{server[:port]}"
      begin
        summary[server_id] = slab_cachedump(server, slab)
      rescue => e
        return exception_message(server_id, e)
      end
    end
    summary
  end

  def general_stats(server)
    response = send(server, 'stats')
    matches = response.map {|line| line.gsub('STAT ', '').strip.split ' '}.flatten
    raw_stats = Hash[*matches]
    stats = {
      up_since: DateTime.strptime(raw_stats['time'], '%s').advance(seconds: "-#{raw_stats['uptime']}".to_i).iso8601,
      total_gets: raw_stats['cmd_get'].to_i,
      total_writes: raw_stats['cmd_set'].to_i,
      evictions: raw_stats['evictions'].to_i,
      get_hits: raw_stats['get_hits'].to_i,
      get_hit_percentage: '0.00%',
      get_misses: raw_stats['get_misses'].to_i,
      get_miss_percentage: '0.00%'
    }
    if stats[:total_gets] > 0
      stats.merge!({
        get_hit_percentage: "#{'%0.2f' % (stats[:get_hits] * 100/stats[:total_gets])}%",
        get_miss_percentage: "#{'%0.2f' % (stats[:get_misses] * 100/stats[:total_gets])}%"
      })
    end
    stats
  end

  def raw_stats_slabs(server)
    response = send(server, 'stats slabs')
    matches = response.map {|line| line.gsub('STAT ', '').strip.split ':'}
    matches.inject({slabs: {}}) do |h, slab_stat|
      Rails.logger.debug "raw_stats_slabs h = #{h}, slab_stat = #{slab_stat}"
      if slab_stat.size > 1
        slab = slab_stat[0]
        stat = Hash[*(slab_stat[1].split ' ')]
        h[:slabs][slab] ||= {}; h[:slabs][slab].merge!(stat)
      else
        stat = (slab_stat[0].split ' ')
        h[stat[0]] = stat[1]
      end
      h
    end
  end

  def raw_stats_items(server)
    response = send(server, 'stats items')
    matches = response.map {|line| line.gsub('STAT items:', '').strip.split ':'}
    matches.inject({}) do |h, slab_stat|
      Rails.logger.debug "raw_stats_items h = #{h}, slab_stat = #{slab_stat}"
      slab = slab_stat[0]
      stat = Hash[*(slab_stat[1].split ' ')]
      h[slab] ||= {}; h[slab].merge!(stat)
      h
    end
  end

  def slab_stats(server)
    stats = {
      slabs: {}
    }
    raw_stats_slabs(server)[:slabs].map do |slab, slab_stats|
      stats[:slabs][slab] = {
        chunk_size: slab_stats['chunk_size'].to_i,
        used_chunks: slab_stats['used_chunks'].to_i,
        hits: slab_stats['get_hits'].to_i,
        writes: slab_stats['cmd_set'].to_i,
        hit_percentage: '0.00%'
      }
      total_tries = stats[:slabs][slab][:hits] + stats[:slabs][slab][:writes]
      if total_tries > 0
        stats[:slabs][slab][:hit_percentage] = "#{'%0.2f' % (stats[:slabs][slab][:hits] * 100/total_tries)}%"
      end
    end
    items = raw_stats_items(server)
    items.map do |slab, item_stats|
      stats[:slabs][slab][:evictions] = item_stats['evicted'].to_i
    end
    stats
  end

  def slab_cachedump(server, slab)
    response = send(server, "stats cachedump #{slab} 0")
    response.map {|line| line.split(' ')[1]}
  end

end
