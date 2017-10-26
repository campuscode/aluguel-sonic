require 'date'

class Proposal < ApplicationRecord
  belongs_to :property

  enum status: { pending: 0, accepted: 1, rejected: 2}

  before_save :calculate_total_amount

  validates :user_name, :email, :start_date, :end_date, :total_guests,
            :rent_purpose, presence: {message: 'Você deve preencher todos os campos'}

  validates :agree_with_rules,
            acceptance: {message: 'Você deve estar de acordo com as regras'}

  validate :total_days_cannot_be_greater_than_property_maximum_days,
           :total_days_cannot_be_less_than_property_minimun_days,
           :total_guests_cannot_be_greater_than_property_maximum_occupancy,
           :reject_proposals_for_unavailable_period

  private

  def reject_proposals_for_unavailable_period
    if property.unavailable_periods.where("start_date_unavailable >= ? AND end_date_unavailable <= ?",
                                           start_date, end_date).any?
      errors.add(:start_date, "Imovel indisponivel para esse periodo")
    end
  end

  def calculate_total_amount
    self.total_amount = date_diff * property.daily_rate
  end

  def total_days_cannot_be_greater_than_property_maximum_days
    if date_diff > property.maximum_rent_days
        errors.add(:start_date, 'Sua proposta extrapolou o número de dias permitidos')
    end
  end

  def total_days_cannot_be_less_than_property_minimun_days
    if date_diff < property.minimum_rent_days
        errors.add(:start_date, 'Sua proposta está abaixo do mínimo número de dias permitidos')
    end
  end

  def date_diff
    if end_date && start_date
      date_diff = (end_date - start_date).to_i
    else
      date_diff = 0
    end
  end

  def total_guests_cannot_be_greater_than_property_maximum_occupancy
    if total_guests
      if total_guests > property.maximum_occupancy
        errors.add(:total_guests, 'Sua proposta está extrapola o número de visitantes permitido')
      end
    end
  end
end
