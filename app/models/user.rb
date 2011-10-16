class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :password, :password_confirmation
  has_many :microposts, :dependent => :destroy
  
  email_regex = /\A[\w+\-.]+@[a-z\-.\d]+\.[a-z]+\z/i
  
  validates :name,      :presence   => true,
                        :length     => { :maximum => 50 }
                        
  validates :email,     :presence   => true,
                        :format     => { :with => email_regex },
                        :uniqueness => { :case_sensitive => false }
                        
  validates :password,  :presence => true,
                        :confirmation => true,
                        :length => { :within => 6..40 }
                      
  before_save :encrypt_password
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def feed
    Micropost.where("user_id = ?", self.id)
  end
  
  
  class << self
    def User.authenticate(email, submitted_password)
      user = find_by_email(email)
      return nil if user.nil?
      (user && user.has_password?(submitted_password)) ? user : nil
    end
    def authenticate_with_salt(id, cookie_salt)
      user = find_by_id(id)
      (user && user.salt == cookie_salt) ? user : nil
    end
  end #appending class methods
  
private
    def encrypt_password
      self.salt = make_salt if self.new_record?
      self.encrypted_password = encrypt(self.password)
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}") #this is, of course not the final, secure version
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
end

# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#

