module ProvidedServices
  extend self

  def calcentral?
    Settings.application.provided_services.include? 'calcentral'
  end

  def bcourses?
    Settings.application.provided_services.include? 'bcourses'
  end
end
