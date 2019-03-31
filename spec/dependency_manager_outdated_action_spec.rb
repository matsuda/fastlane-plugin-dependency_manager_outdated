describe Fastlane::Actions::DependencyManagerOutdatedAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The dependency_manager_outdated plugin is working!")

      Fastlane::Actions::DependencyManagerOutdatedAction.run(nil)
    end
  end
end
