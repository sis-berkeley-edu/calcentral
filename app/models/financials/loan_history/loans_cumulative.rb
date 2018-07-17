module Financials
  module LoanHistory
    class LoansCumulative < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include ClassLogger
      include Concerns::LoanHistoryModule
      include User::Identifiers

      def merge(data)
        data.merge!(get_feed)
      end

      def get_feed_internal
        return { loans: nil, loansSummary: nil } unless is_loan_history_active? campus_solutions_id
        loans, loans_summary = get_loan_data
        { loans: loans, loansSummary: loans_summary }
      end

      def get_loan_data
        data = EdoOracle::Queries.get_loan_history_categories_cumulative || []
        parse_loan_categories HashConverter.camelize(data)
      end

      def parse_loan_categories(loans_data)
        loan_types = [].tap do |loans|
          loans_data.try(:each) do |loan|
            loan_category = loan.try(:[], :categoryTitle)
            loans.push([loan_category,
              {
                category: loan_category,
                loans: [],
                sequence: loan.try(:[], :parentSequence).try(:to_i),
                totals: { amountOwed: 0, estMonthlyPayment: 0 }
              }])
          end
        end.uniq!
        loans_hash = loan_types.to_h
        parse_loan_details(loans_hash, loans_data)
      end

      def parse_loan_details(loans_hash, loans_data)
        loans_data.try(:each) do |loan|
          loan_category = loan.try(:[], :categoryTitle)
          loan_obj =
            {
              amountOwed: nil,
              estMonthlyPayment: nil,
              loanType: loan.try(:[], :loanType),
              sequence: loan.try(:[],:childSequence).try(:to_i)
            }

          unless loans_hash[loan_category].try(:[], :hasDescr)
            loan_descr = enrolled_pre_fall_2016?(campus_solutions_id) ? loan.try(:[], :categoryDescr) + ' ' + loan.try(:[], :categoryDescrPre2168) : loan.try(:[], :categoryDescr)
            loans_hash[loan_category][:descr] = loan_descr
            loans_hash[loan_category][:hasDescr] = true
          end

          if (loan_child_view = loan.try(:[], :loanChildVw))
            amount = get_loan_amount loan_child_view
            est_monthly_payment = calculate_estimated_monthly_payment(loan.try(:[], :loanInterestRate), amount.try(:[], 'amount'), loan.try(:[], :loanDuration))
            parsed_amount = parse_owed_value(amount.try(:[], 'amount').try(:to_f).try(:round, 2))
            parsed_est_monthly_payment = parse_owed_value(est_monthly_payment)
            minimum_monthly_payment = loan.try(:[], :minLoanAmt)
            monthly_payment = parsed_amount > 0 ? parse_owed_value(choose_monthly_payment(parsed_est_monthly_payment, minimum_monthly_payment)) : 0

            add_amounts_to_running_total(loans_hash, loan_category, parsed_amount, monthly_payment)
            loan_obj.merge!(
              {
                amountOwed: parsed_amount,
                estMonthlyPayment: monthly_payment
              })
          else
            logger.error("#{loan.try(:[], :loanType)} child view missing for UID #{@uid}")
          end
          loans_hash[loan_category][:loans].push(loan_obj)
        end
        calculate_cumulative_totals loans_hash
      end

      def calculate_cumulative_totals (loans_hash)
        cumulative_amount = 0
        cumulative_monthly_payment = 0
        loans_hash.each_value do |loan_category|
          cumulative_amount += loan_category.try(:[], :totals).try(:[], :amountOwed) || 0
          cumulative_monthly_payment += loan_category.try(:[], :totals).try(:[], :estMonthlyPayment) || 0
        end
        loans_summary = { amountOwed: parse_owed_value(cumulative_amount), estMonthlyPayment: parse_owed_value(cumulative_monthly_payment) }
        remove_temporary_properties(loans_hash, loans_summary)
      end

      def remove_temporary_properties(loans_hash, loans_summary)
        loans_hash.each_value do |loan_category|
          loan_category.delete(:hasDescr)
        end
        convert_loans_to_array(loans_hash, loans_summary)
      end

      def convert_loans_to_array(loans_hash, loans_summary)
        return loans_hash.values, loans_summary
      end

      def add_amounts_to_running_total(loans_hash, loan_category, amount, est_monthly_payment)
        loans_hash[loan_category][:totals][:amountOwed] += amount
        loans_hash[loan_category][:totals][:estMonthlyPayment] += est_monthly_payment
      end

      def get_loan_amount(view_name)
        EdoOracle::Queries.get_loan_history_cumulative_loan_amount(campus_solutions_id, view_name)
      end

      def campus_solutions_id
        @cs_id ||= lookup_campus_solutions_id
      end

    end
  end
end
