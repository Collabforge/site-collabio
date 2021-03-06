class NetworkMembershipRequestsController < BaseController
  def new
    @request = NetworkMembershipRequest.new
  end

  def create
    @request = NetworkMembershipRequest.new permitted_params.network_membership_request
    NetworkMembershipRequestService.create network_membership_request: @request, actor: current_user
    flash[:notice] = I18n.t(:'networks.request_created')
    redirect_to network_path(@request.network)
  end

  def index
    @network = Network.friendly.find params[:network_id]
    @requests = @network.membership_requests
    current_user.ability.authorize! :manage_membership_requests, @network
  end

  def approve
    @network = Network.friendly.find params[:network_id]
    @request = @network.membership_requests.find params[:id]
    NetworkMembershipRequestService.approve(network_membership_request: @request, actor: current_user)
    flash[:notice] = I18n.t(:'networks.request_approved')
    redirect_to @network
  end

  def decline
    @network = Network.friendly.find params[:network_id]
    @request = @network.membership_requests.find params[:id]
    NetworkMembershipRequestService.decline(network_membership_request: @request, actor: current_user)
    flash[:notice] = I18n.t(:'networks.request_declined')
    redirect_to @network
  end
end