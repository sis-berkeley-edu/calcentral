describe HubEdos::StudentApi::V2::StudentRecord::Gpa do
  let(:attributes) do
    {
      'type' => {
        'code' => 'CGPA',
        'description' => 'Cumulative GPA'
      },
      'average' => 2.43,
      'source' => 'UCB'
    }
  end
end
