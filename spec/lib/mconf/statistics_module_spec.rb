# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2018 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::StatisticsModule do
  let(:start_date) { Time.now.utc.beginning_of_day }
  let(:end_date) { Time.now.utc.end_of_day }
  let(:created_date) { Time.now.utc }
  let!(:user) { FactoryGirl.create(:user, created_at: created_date) }
  let!(:space) { FactoryGirl.create(:space, created_at: created_date) }
  let!(:meeting) { FactoryGirl.create(:bigbluebutton_meeting, created_at: created_date) }
  let!(:recording) { FactoryGirl.create(:bigbluebutton_recording, start_time: 15, end_time: 20) }
  subject { Mconf::StatisticsModule }

  describe "total_users" do
    let(:data) { {:all=>2, :approved=>2, :not_approved=>0, :disabled=>0} }
    let(:nil_data) { {:all=>0, :approved=>0, :not_approved=>0, :disabled=>0} }

    it "function with arguments returns 'user' and with nil returns 0" do
      subject.total_users(start_date, end_date).should eql(data)
      subject.total_users(nil, nil).should eql(nil_data)
    end
  end

  describe "total_spaces" do
    let(:data) { {:all=>1, :private=>1, :public=>0, :disabled=>0} }
    let(:nil_data) { {:all=>0, :private=>0, :public=>0, :disabled=>0} }

    it "function with arguments returns 'space' and with nil returns 0" do
      subject.total_spaces(start_date, end_date).should eql(data)
      subject.total_spaces(nil, nil).should eql(nil_data)
    end
  end

  describe "total_meetings" do
    let(:data) { {:all=>1, :average=>0, :total=>0} }
    let(:nil_data) { {:all=>0, :average=>0, :total=>0} }

    it "function with arguments returns 'meeting' and with nil returns 0" do
      subject.total_meetings(start_date, end_date).should eql(data)
      subject.total_meetings(nil, nil).should eql(nil_data)
    end
  end

  describe "total_recordings" do
    let(:data) { {:all=>1, :size=>0, :average=>5, :total=>5} }
    let(:nil_data) { {:all=>0, :size=>0, :average=>0, :total=>0} }

    it "function with arguments returns 'recording' and with nil returns 0" do
      subject.total_recordings(start_date, end_date).should eql(data)
      subject.total_recordings(nil, nil).should eql(nil_data)
    end
  end

  describe "generate" do
    let(:data) { {:users=>{:all=>2, :approved=>2, :not_approved=>0, :disabled=>0}, :spaces=>{:all=>1, :private=>1, :public=>0, :disabled=>0}, :meetings=>{:all=>1, :average=>0, :total=>0}, :recordings=>{:all=>1, :size=>0, :average=>5, :total=>5}}}
    let(:nil_data) { {:users=>{:all=>0, :approved=>0, :not_approved=>0, :disabled=>0}, :spaces=>{:all=>0, :private=>0, :public=>0, :disabled=>0}, :meetings=>{:all=>0, :average=>0, :total=>0}, :recordings=>{:all=>0, :size=>0, :average=>0, :total=>0}} }

    it "function with arguments returns 'user, space, meeting and recording' (all data) and with nil returns nothing" do
      subject.generate(start_date, end_date).should eql(data)
      subject.generate(nil, nil).should eql(nil_data)
    end
  end

  describe "generate_csv" do
    let(:data) {"users.all,users.approved,users.not_approved,users.disabled,spaces.all,spaces.private,spaces.public,spaces.disabled,meetings.all,meetings.average,meetings.total,recordings.all,recordings.size,recordings.average,recordings.total\n2,2,0,0,1,1,0,0,1,0,0,1,0,5,5\n"}

    it "function with arguments returns file .csv and with nil returns nil" do
      subject.generate_csv(start_date, end_date).should eql(data)
      subject.generate_csv(nil, nil).should eql(nil)
    end
  end
end
