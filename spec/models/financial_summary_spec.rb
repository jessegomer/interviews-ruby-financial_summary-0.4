require 'rails_helper'

describe FinancialSummary do
  it 'summarizes over one day' do

    user = create(:user)

    Timecop.freeze(Time.now) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(2.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.one_day(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
  end

  it 'summarizes over seven days' do

    user = create(:user)

    Timecop.freeze(5.days.ago) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(8.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.seven_days(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
  end

  it 'summarizes over lifetime' do

    user = create(:user)

    Timecop.freeze(30.days.ago) do
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
      create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))
    end

    Timecop.freeze(8.days.ago) do
      create(:transaction, user: user, category: :deposit)
    end

    subject = FinancialSummary.lifetime(user: user, currency: :usd)
    expect(subject.count(:deposit)).to eq(3)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(13.12, :usd))
  end

  it 'selects the correct currency' do
    user = create(:user)

    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))

    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(40.21, :cad))
    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(33, :cad))

    subject = FinancialSummary.lifetime(user: user, currency: :cad)
    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(73.21, :cad))
  end

  it 'handles multiple types of transactions' do
    user = create(:user)

    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(2.12, :usd))
    create(:transaction, user: user, category: :deposit, amount: Money.from_amount(10, :usd))

    create(:transaction, user: user, category: :refund, amount: Money.from_amount(40.21, :usd))

    create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(10, :usd))
    create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(20, :usd))
    create(:transaction, user: user, category: :withdraw, amount: Money.from_amount(30, :usd))

    subject = FinancialSummary.lifetime(user: user, currency: :usd)

    expect(subject.count(:deposit)).to eq(2)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))
    expect(subject.count(:refund)).to eq(1)
    expect(subject.amount(:refund)).to eq(Money.from_amount(40.21, :usd))
    expect(subject.count(:withdraw)).to eq(3)
    expect(subject.amount(:withdraw)).to eq(Money.from_amount(60, :usd))
  end

  it 'handles empty summaries' do
    user = create(:user)
    subject = FinancialSummary.lifetime(user: user, currency: :usd)

    expect(subject.count(:deposit)).to eq(0)
    expect(subject.amount(:deposit)).to eq(Money.from_amount(0, :usd))
  end

  it 'summarizes when there are multiple users' do
    user_1 = create(:user)
    user_2 = create(:user)
    
    create(:transaction, user: user_1, category: :deposit, amount: Money.from_amount(15, :usd))
    create(:transaction, user: user_2, category: :deposit, amount: Money.from_amount(10, :usd))
    create(:transaction, user: user_2, category: :deposit, amount: Money.from_amount(10, :usd))

    user_1_summary = FinancialSummary.lifetime(user: user_1, currency: :usd)
    user_2_summary = FinancialSummary.lifetime(user: user_2, currency: :usd)

    expect(user_1_summary.count(:deposit)).to eq(1)
    expect(user_2_summary.count(:deposit)).to eq(2)
  end


end
