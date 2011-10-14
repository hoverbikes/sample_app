Factory.define :user do |user|
  
  user.sequence (:name)         { |n| "Michael Hartl #{n}"}
  user.sequence (:email)        { |n| "mhartl#{n}@example.com" }
  user.password                 "foobar"
  user.password_confirmation    "foobar"
  
end