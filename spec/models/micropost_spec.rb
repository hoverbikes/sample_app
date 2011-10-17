require 'spec_helper'

describe Micropost do
  before(:each) do
    @user = Factory(:user)
    @attr = {:content => "blah blah blah"}
  end

  it "should create a new instance with valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user associations" do
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end #user associations
  
  describe "validations" do
    it "should have a user id" do
      Micropost.new(@attr).should_not be_valid
    end
    it "should require nonblank content" do
      @user.microposts.build(:content => "    ").should_not be_valid      
    end
    it "should reject overlong content" do
      @user.microposts.build(:content => "x" * 141).should_not be_valid
    end
  end
  
  describe "from_users_followed_by method" do
    before(:each) do
      @other_user = Factory(:user)
      @third_user = Factory(:user)
      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")
      @user.follow!(@other_user)
    end
    it "should have a from_users_followed_by method" do
      Micropost.should respond_to(:from_users_followed_by)
    end
    it "should include the followed users' microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end
    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end
    it "should not include microposts from unfollowed users" do
      Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
          
  end # the from_users_followed_by method
  
end #Micropost

# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

