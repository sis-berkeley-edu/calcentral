shared_examples 'a proxy that returns all available, non user-specific data' do

  it 'returns all general messaging' do
    expect(subject[:messaging]).to be_truthy
    expect(subject[:messaging]).to include :estimatedPaymentDisclaimer
  end

  it 'returns all general links' do
    expect(subject[:links]).to be_truthy
    expect(subject[:links]).to have(4).items
  end

  it 'returns all general glossary definitions' do
    expect(subject[:glossary]).to be_truthy
    expect(subject[:glossary]).to have(3).items
  end

end
