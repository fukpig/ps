require 'test_helper'

class WorkersControllerTest < ActionController::TestCase
  setup do
    @worker = workers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workers)
  end

  test "should create worker" do
    assert_difference('Worker.count') do
      post :create, worker: { email: @worker.email, name: @worker.name, password: @worker.password, phone: @worker.phone, user_id: @worker.user_id }
    end

    assert_response 201
  end

  test "should show worker" do
    get :show, id: @worker
    assert_response :success
  end

  test "should update worker" do
    put :update, id: @worker, worker: { email: @worker.email, name: @worker.name, password: @worker.password, phone: @worker.phone, user_id: @worker.user_id }
    assert_response 204
  end

  test "should destroy worker" do
    assert_difference('Worker.count', -1) do
      delete :destroy, id: @worker
    end

    assert_response 204
  end
end
