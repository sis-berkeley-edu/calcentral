module EdwOracle
  class Queries < Connection
    include ActiveRecordHelper
    include ClassLogger

    def self.get_socio_econ(advisee_sids)
      batched_sids = advisee_sids.each_slice(1000).to_a
      full_sql = ''
      batched_sids.each do |sids|
        if full_sql.present?
          full_sql << ' UNION ALL '
        end
        sids_in = sids.map {|sid| "'#{sid}'"}.join ','
        sql = <<-SQL
          SELECT
            pp.student_id AS sid,
            adv.last_school_lcff_flg AS lcff, 
            adv.first_generation_college_flg AS first_gen,
            adv.low_socio_economic_status_flg AS socio_econ,
            afv.parent_income_amt AS parent_income
          FROM ENTERPRISE.ETS_PERSON_PARTY_D_V pp
          LEFT JOIN ENTERPRISE.STUDENT_APPLICATION_D_V adv ON pp.person_party_sk = adv.person_party_sk
          LEFT JOIN ENTERPRISE.STUDENT_APPLICATIONS_F_V afv ON pp.person_party_sk = afv.person_party_sk
          WHERE pp.source_system_cd=11
            AND pp.student_id IN (#{sids_in})
        SQL
        full_sql << sql
      end
      safe_query(full_sql, do_not_stringify: true)
    end

    def self.get_applicant_scores(advisee_sids)
      batched_sids = advisee_sids.each_slice(1000).to_a
      full_sql = ''
      batched_sids.each do |sids|
        if full_sql.present?
          full_sql << ' UNION ALL '
        end
        sids_in = sids.map {|sid| "'#{sid}'"}.join ','
        sql = <<-SQL
          SELECT
            pp.student_id as sid,
            apty.test_score_type_cd, 
            apty.test_score_subject_desc,
            apsc.test_score_nbr, 
            sapps.applied_school_yr
          FROM ENTERPRISE.ETS_PERSON_PARTY_D_V pp
          LEFT JOIN ENTERPRISE.STUDENT_APPLICATIONS_F_V sapps ON pp.person_party_sk = sapps.person_party_sk
          LEFT JOIN ENTERPRISE.APPLICANT_TEST_SCORES_F_v apsc ON apsc.student_application_sk=sapps.student_application_sk
          LEFT JOIN ENTERPRISE.APPLICANT_TEST_SCORE_TYPE_D_V apty ON apty.test_score_type_sk=apsc.test_score_type_sk
          WHERE pp.source_system_cd=11 
            AND pp.student_id IN (#{sids_in})
        SQL
        full_sql << sql
      end
      full_sql << <<-SQLA
        ORDER BY sid, applied_school_yr DESC, test_score_type_cd
      SQLA
      safe_query(full_sql, do_not_stringify: true)
    end

  end
end
