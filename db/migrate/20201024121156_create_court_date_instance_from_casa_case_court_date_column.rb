class CreateCourtDateInstanceFromCasaCaseCourtDateColumn < ActiveRecord::Migration[6.0]
  def up
    CasaCase.all.each do |cc|
      if cc.court_date
        CourtDate.create!(date: cc.court_date, casa_case_id: cc.id)
      end
    end
  end

  def down
    CourtDate.all.each do |cd|
      cd.destroy!
    end
  end
end
