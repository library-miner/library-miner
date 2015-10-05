class Base < ActiveJob::Base
  def exec_job(&block)
    yield
  end
end
