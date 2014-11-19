require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  setup do
    @domain = domains(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should create domain" do
    assert_difference('Domain.count') do
      post :create, domain: { domain: @domain.domain, expiry_date: @domain.expiry_date, ns_list: @domain.ns_list, registration_date: @domain.registration_date, status: @domain.status, user_id: @domain.user_id }
    end

    assert_response 201
  end

  test "should show domain" do
    get :show, id: @domain
    assert_response :success
  end

  test "should update domain" do
    put :update, id: @domain, domain: { domain: @domain.domain, expiry_date: @domain.expiry_date, ns_list: @domain.ns_list, registration_date: @domain.registration_date, status: @domain.status, user_id: @domain.user_id }
    assert_response 204
  end

  test "should destroy domain" do
    assert_difference('Domain.count', -1) do
      delete :destroy, id: @domain
    end

    assert_response 204
  end
end
