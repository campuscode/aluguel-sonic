class ProposalsController < ApplicationController

  def new
    @property = Property.find(params[:property_id])
    @proposal = Proposal.new
  end

  def create
    @property = Property.find(params[:property_id])
    @proposal = @property.proposals.new(proposal_params)
    if @proposal.save
      NewProposalMailer.email_new_proposals
      flash[:notice] = 'Proposta enviada com sucesso.'
      redirect_to @proposal
    else
      render :new
    end
  end

  def show
    @proposal = Proposal.find(params[:id])
  end

  def accept
    proposal_accepted = Proposal.find(params[:id])
    property_of_the_proposal = proposal_accepted.property
    reject_proposals(proposal_accepted, property_of_the_proposal)
    if proposal_accepted.accepted!
      flash[:notice] = "Proposta Aceita"
      ProposalsMailer.accept_proposal
    else
      render :show
    end
      redirect_to proposal_path
  end

  def index
    properties = current_owner.properties
    @proposals = []
    properties.each do |property|
      @proposals << property.proposals
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:user_name, :email, :start_date, :end_date,
                                :total_guests, :rent_purpose, :agree_with_rules)
  end

  def reject_proposals(proposal_accepted, property_of_the_proposal)
    rejected = property_of_the_proposal.proposals.where("start_date >= ? AND end_date <= ?",
                                                  proposal_accepted.start_date, proposal_accepted.end_date)
    rejected.each { |e| e.rejected!  }
  end

end
