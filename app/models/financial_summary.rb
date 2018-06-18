class FinancialSummary
  attr_reader :user, :currency, :start_date

  def self.one_day(user:, currency: :usd)
    new(user: user, currency: currency, start_date: Time.now - 1.days)
  end

  def self.seven_days(user:, currency: :usd)
    new(user: user, currency: currency, start_date: Time.now - 7.days)
  end

  def self.lifetime(user:, currency: :usd)
    new(user: user, currency: currency)
  end

  def initialize(user:, currency: :usd, start_date: nil)
    @user = user
    @currency = currency.to_s.upcase
    @start_date = start_date

    @counts = Hash.new(0)
    @amounts = Hash.new{|hash, key| hash[key] = Money.from_amount(0, currency)}

    load_summary
  end

  def load_summary
    transactions = Transaction.where(user_id: user.id, amount_currency: currency)

    if start_date.present?
      transactions = transactions.where('created_at >= ?', start_date )
    end

    transactions.each do |transaction|
      category = transaction.category.to_sym
      @counts[category] += 1
      @amounts[category] += transaction.amount
    end

  end

  def amount(category)
    @amounts[category]
  end

  def count(category)
    @counts[category]
  end

end