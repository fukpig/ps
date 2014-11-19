json.array!(@domains) do |domain|
  json.extract! domain, :id, :user_id, :registration_date, :domain, :expiry_date, :status, :ns_list
  json.url domain_url(domain, format: :json)
end
