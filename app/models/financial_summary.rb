class FinancialSummary
  attr_reader :user

  def self.one_day(user=nil, currency=:usd)
    new(user).generate_summary(currency, Time.now - 1.days)
  end

  def self.seven_days(user=nil, currency=:usd)
    new(user).generate_summary(currency, Time.now - 7.days)
  end

  def self.lifetime(user=nil, currency=:usd)
    new.generate_summary(user, currency)
  end

  def initialize(user)
    if user.nil?
      raise ArgumentError('FinancialSummary requires a user')
    end
    @user = user
  end

  def generate_summary(currency=:usd, start_date=nil)
    transactions = user.trac



  end



end