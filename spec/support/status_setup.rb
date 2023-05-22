module StatusSetup
  def mock_status(status, success: nil)
    calculated_success = success.nil? ? status == 0 : success
    instance_double(Process::Status, success?: calculated_success, exitstatus: status)
  end

  def stub_capture3(output: "fake output", error: "fake error", status: 0)
    mock_status(status).tap do |stat|
      allow(Open3).to receive(:capture3).and_return([output, error, stat])
    end
  end
end

RSpec.configure do |config|
  config.include StatusSetup
end
