json.array!(@workers) do |worker|
  json.extract! worker, :id, :user_id, :name, :email, :password, :phone
  json.url worker_url(worker, format: :json)
end
