module CourtOrdersHelper
  def court_order_select_options
    CaseCourtOrder.implementation_statuses.map do |status|
      [status[0].humanize, status[0]]
    end
  end
end
