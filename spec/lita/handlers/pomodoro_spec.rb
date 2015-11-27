require "spec_helper"

describe Lita::Handlers::Pomodoro, lita_handler: true do

  let(:robot) { Lita::Robot.new(registry) }
  let(:dur) { 25 }
  let(:mention_name) { subject.linked_mention_name(user) }

  subject { described_class.new(robot) }

  # Test chat routes

  it { is_expected.to route_command("start").to(:start) }
  it { is_expected.to route_command("60").to(:start) }
  it { is_expected.to route_command("until 5:00pm").to(:start) }
  it { is_expected.to route_command("stop").to(:stop) }
  it { is_expected.to route_command("list").to(:list) }
  it { is_expected.to route_command("@boss yo").to(:auto_respond) }

  # Test behaviors

  describe "#start" do
    it "should respond when you start a new pomodoro session" do
      expect(Lita::Timer).to receive(:after) do |&arg|
        arg.call
      end
      send_command("start")
      active_users = Lita::User.find_by_pomodoro
      user = active_users.last
      expect(replies.first).to eq("#{mention_name}: Starting pomodoro session for #{dur.to_s} minutes (until #{Time.parse(user.metadata["pomodoro_stop"]).strftime("%l:%M%P")}).")
      expect(replies.last).to eq("#{mention_name}: Your pomodoro session has ended!")
    end

    it "should respond when you restart an existing pomodoro session" do
      send_command("start")
      active_users = Lita::User.find_by_pomodoro
      user = active_users.last
      send_command("start", as: user)
      expect(replies.last).to eq("#{mention_name}: Restarting existing pomodoro session for #{dur.to_s} minutes (until #{Time.parse(user.metadata["pomodoro_stop"]).strftime("%l:%M%P")}).")
    end
  end

  describe "#stop" do
    it "should respond when you stop pomodoro session" do
      send_command("start")
      active_users = Lita::User.find_by_pomodoro
      user = active_users.last
      send_command("stop", as: user)
      expect(replies.last).to eq("#{mention_name}: Stopping your pomodoro session.")
    end

    it "should respond when you stop pomodoro session but you weren't pomodoroing" do
      send_command("stop")
      expect(replies.last).to eq("#{mention_name}: You weren't pomodoroing.")
    end
  end

  describe "#list" do
    it "should respond when you request list of active pomodoros but there are no active pomodoros" do
      send_command("list")
      expect(replies.last).to eq("No pomodoros currently!")
    end

    it "should respond when you request list of active pomodoros and there are active pomodoros" do
      send_command("start")
      active_users = Lita::User.find_by_pomodoro
      send_command("list")
      expect(replies.last).to eq("Currently pomodoroing:\n#{active_users.map{|u| "#{u.name} (until #{Time.parse(u.metadata["pomodoro_stop"]).strftime("%l:%M%P")})" }.join("\n")}")
    end
  end

  describe "#auto_respond" do
    it "should send an autoresponse when you try to chat at someone who's pomodoroing" do
      user1 = Lita::User.create(123, name: "boss")
      send_command("start", as: user1)
      active_users = Lita::User.find_by_pomodoro
      user1 = active_users.last
      send_message("@#{user1.name}: Can I bug you with an annoying question?")
      expect(replies.last).to eq("#{mention_name}: #{user1.name} is currently pomodoroing, until #{Time.parse(user1.metadata["pomodoro_stop"]).strftime("%l:%M%P")}.")
    end
  end

  describe "#linked_mention_name" do
    it "should return user name when given a user" do
      expect(subject.linked_mention_name(user)).to eq(user.name)
    end
  end
end
