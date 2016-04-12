require 'sinatra'
require 'stripe'
require 'dotenv'

Dotenv.load

api_keys = {
  'H' => ENV['1'],
  'S' => ENV['2'],
  'C' => ENV['3'],
  'A' => ENV['4'] 
}

Stripe.api_key = api_keys['H']

get '/' do
  status 200
  return "Great, your backend is set up. Now you can configure the Stripe example iOS apps to point here."
end

post '/charge' do
  # Get the credit card details submitted by the form
  token = params[:stripeToken]
  country = params[:country]

  Stripe.api_key = api_keys[country[0,1]]

  # Create the charge on Stripe's servers - this will charge the user's card
  begin
    charge = Stripe::Charge.create(
      :amount => params[:amount], # this number should be in cents
      :currency => "usd",
      :recurring => "false",
      :card => token,
      :description => "Example Charge"
    )
  rescue Stripe::CardError => e
    status 402
    return "Error creating charge."
  end

  status 200
  return "Order successfully created"

end

post '/recurring' do
  # Get the credit card details submitted by the form
  token = params[:stripeToken]
  country = params[:country]
  Stripe.api_key = api_keys[country[0,1]]
  
  # Create the charge on Stripe's servers - this will charge the user's card
  begin
    customer = Stripe::Customer.create(
      :source => token      
    )
    charge = Stripe::Charge.create(
      :amount => params[:amount], # this number should be in cents
      :currency => "usd",
      :source => customer.id,
      :recurring => "true",
      :description => "Example Recurring Charge"
    )
  rescue Stripe::CardError => e
    status 402
    return "Error creating charge."
  end

  status 200
  return "Recurring payment successfully created"

end
