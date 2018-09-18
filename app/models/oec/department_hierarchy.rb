module Oec
  class DepartmentHierarchy < Worksheet

    def headers
      %w(NODE_ID NODE_CAPTION PARENT_NODE_ID PARENT_NODE_CAPTION LEVEL)
    end

    def university_row()
      {
        'NODE_ID' => 'UC Berkeley',
        'NODE_CAPTION' => 'UC Berkeley',
        'PARENT_NODE_ID' => nil,
        'PARENT_NODE_CAPTION' => nil,
        'LEVEL' => 1
      }
    end

    def department_row(dept_name)
      {
        'NODE_ID' => dept_name,
        'NODE_CAPTION' => dept_name,
        'PARENT_NODE_ID' => 'UC Berkeley',
        'PARENT_NODE_CAPTION' => 'UC Berkeley',
        'LEVEL' => 2
      }
    end

  end
end
