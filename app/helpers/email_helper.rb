module EmailHelper
  	
  def generate_email(data)
  	emails_a = []
  	firstname = Russian.translit(data[:firstname])
  	lastname = Russian.translit(data[:lastname])

  	#igor@domain.com
  	if !firstname.empty?
  	  email = "#{firstname}@#{data[:domain]}"
  	  email = assort_email(data[:domain], firstname ) unless available? email
  	  	emails_a << email

  	end

  	#77774705775@domain.com
  	emails_a << "#{data[:phone]}@#{data[:domain]}"
  end


  def available?(email)
  	email = EmailAccount.where(:email => email).first
  	return true unless email
  end

  def assort_email(domain, firstname)
  	available = false
  	counter = 1
  	while available == false  do
  		email = "#{firstname}#{counter}@#{domain}"
  		available = available? email
  		counter += 1
  	end
  	return email
  end
end