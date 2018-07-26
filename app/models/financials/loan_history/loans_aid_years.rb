module Financials
  module LoanHistory
    class LoansAidYears < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Concerns::LoanHistoryModule
      include User::Identifiers

      UNKNOWN = 'UNK'

      def merge(data)
        data.merge!(get_feed)
      end

      def get_feed_internal
        return { aidYears: nil } unless is_loan_history_active? campus_solutions_id
        { aidYears: get_loan_data }
      end

      def get_loan_data
        data = EdoOracle::Queries.get_loan_history_categories_aid_years campus_solutions_id
        parse_loan_aid_years HashConverter.camelize(data)
      end

      def parse_loan_aid_years(loans_data)
        # Put each aid_year from the returned payload into an array, remove duplicates, and convert it to a hash
        loans_hash = loans_data.map { |loan| loan.try(:[], :aidYear) }.uniq.map { |aid_year| [aid_year, { aidYear: aid_year, aidYearFormatted: format_aid_year_name(aid_year), loans: [] }] }.to_h
        get_loan_details(loans_hash, loans_data)
      end

      def get_loan_details(loans_hash, loans_data)
        child_loans_hash = {}
        loans_data.each do |loan|
          loan_type = loan.try(:[], :loanType)

          if (loan_child_view = loan.try(:[], :loanChildVw))
            unless child_loans_hash.has_key? loan_type
              child_loan_details = get_child_loan_details(loan_child_view)
              relevant_loans_config = loans_data.find_all { |loan_config|  loan_config.try(:[], :loanType) == loan_type }
              child_loans_hash[loan_type] = parse_child_loan_details(relevant_loans_config, HashConverter.camelize(child_loan_details))
            end
          end
        end
        parse_loan_details(loans_hash, child_loans_hash)
      end

      def parse_child_loan_details(loans_config, loan_details)
        loans_hash = loan_details.map { |loan| [loan.try(:[], :aidYear), {loans: []}] }.to_h
        loan_details.each do |loan|
          aid_year = loan.try(:[], :aidYear)
          relevant_loan_config = loans_config.find { |loan_config| loan_config.try(:[], :aidYear) == aid_year }

          amount = loan.try(:[], :loanAmount)
          interest_rate = find_interest_rate(relevant_loan_config, loan)
          interest_visible = show_interest_rate? loan
          est_monthly_payment = calculate_estimated_monthly_payment(interest_rate, amount, relevant_loan_config.try(:[], :loanDuration))
          minimum_monthly_payment = amount > 0 ? choose_monthly_payment(est_monthly_payment, relevant_loan_config.try(:[], :minLoanAmt), amount) : 0

          loans_hash[aid_year][:loans].push({
            amountOwed: parse_owed_value(amount),
            estMonthlyPayment: parse_owed_value(minimum_monthly_payment),
            interestRate: interest_visible ? parse_owed_value(interest_rate) : nil,
            loanCategory: loan.try(:[], :loanCategory),
            loanDescr: loan.try(:[], :loanDescr),
            sequence: relevant_loan_config.try(:[], :sequence).try(:to_i)
          })
        end
        loans_hash
      end

      def parse_loan_details(loans_hash, child_loans_hash)
        child_loans_hash.each do |loan_category, aid_years|
          aid_years.each do |aid_year, loans_obj|
            loans_hash[aid_year][:loans].concat(loans_obj[:loans])
          end
        end
        add_aid_year_totals loans_hash
      end

      def add_aid_year_totals(loans_hash)
        loans_hash.each do |aid_year, loan_obj|
          aid_year_total = loan_obj[:loans].reduce(0) { |memo, loan| memo += loan.try(:[], :amountOwed).to_f }
          loans_hash[aid_year][:totalAmountOwed] = parse_owed_value aid_year_total
        end
        convert_hash_to_array loans_hash
      end

      def convert_hash_to_array(loans_hash)
        loans_hash.values
      end

      def find_interest_rate(loan_config, loan_detail)
        if use_interest_rate_from_config? loan_detail
          interest_rate = loan_config.try(:[], :loanInterestRate)
        else
          interest_rate = loan_detail.try(:[], :interestRate)
        end
        interest_rate.to_f
      end

      def format_aid_year_name(aid_year)
        aid_year_int = aid_year.to_i
        (aid_year_int - 1).to_s + " - " + aid_year.to_s
      end

      def get_child_loan_details(view_name)
        EdoOracle::Queries.get_loan_history_aid_years_details(campus_solutions_id, view_name)
      end

      def campus_solutions_id
        @cs_id = lookup_campus_solutions_id
      end

      def show_interest_rate?(loan)
        loan.try(:[], :interestRate) != UNKNOWN
      end

      def use_interest_rate_from_config?(loan)
        interest = loan.try(:[], :interestRate)
        interest == 'CONFIG' || interest == UNKNOWN
      end

    end
  end
end
