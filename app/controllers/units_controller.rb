class UnitsController < ApplicationController

  before_action :authenticate_unit!
  before_action :check_rules_global_admin, except: [ :index, :admin_branches, :show, :new, :create, :edit, :update, :destroy]
  before_action :check_rules_global_moderator, except: [ :index, :admin_branches, :show, :edit, :update]
  before_action :check_rules_organization_admin, except: [ :index, :show, :new, :create, :edit, :update, :destroy]
  before_action :check_rules_organization_moderator , except: [ :index, :show, :edit, :update]
  before_action :check_rules_departament_admin , except: [ :index, :show, :new, :create, :edit, :update, :destroy]
  before_action :check_rules_departament_moderator , except: [ :index, :show, :edit, :update]
  before_action :check_rules_user, except: [:index, :show, :units_self_admin]
  before_action :organizations_isolation
  
  def index
    if !current_unit.global_admin? && !current_unit.global_moderator?
      organizations_isolation
    end
  end

  def show
    if !current_unit.role == 'global_admin' || !current_unit.role == 'global_moderator'
      organizations_isolation
    end
  end

  def new
    if units.empty? 
        new_unit
    elsif current_unit.global_admin?
      global_admin_role
      new_unit
    elsif current_unit.global_moderator?
      global_moderator_role
      new_unit
    elsif current_unit.organization_admin?
      organization_admin_role
      new_unit
     elsif current_unit.departament_admin?
      departament_admin_role
      new_unit
    else
      redirect_to organization_departament_units_path(organization, departament)
    end
  end

  def create
    if units.empty?
      create_unit
    elsif current_unit.global_admin?
      global_admin_role
      create_unit
    elsif current_unit.global_moderator?
      global_moderator_role
      create_unit
    elsif current_unit.organization_admin?
      organization_admin_role
      create_unit
     elsif current_unit.departament_admin?
      departament_admin_role
      create_unit
    else
      redirect_to organization_departament_units_path(organization, departament, unit)
    end
  end

  def edit
    if current_unit.global_admin?
      global_admin_role
    elsif current_unit.global_moderator?
      global_moderator_role
    elsif current_unit.organization_admin?
      organization_admin_role
    elsif current_unit.organization_moderator?
      organization_moderator_role
    elsif current_unit.departament_admin?
      departament_admin_role
    elsif current_unit.departament_moderator?
      departament_moderator_role
    elsif current_unit.units_admin?
      if current_unit.id.to_i == unit.id.to_i
        units_admin_role
      else 
        redirect_to organization_departament_units_path(organization, departament, unit)
      end
    else
      redirect_to organization_departament_units_path(organization, departament, unit)
    end
  end

  def update
    def updation_unit
      if unit.update(unit_params)
        redirect_to organization_departament_units_path(organization, departament.id)
      end
    end
    if current_unit.global_admin?
      global_admin_role
      updation_unit
    elsif current_unit.global_moderator?
      global_moderator_role
      updation_unit
    elsif current_unit.organization_admin?
      organization_admin_role
      updation_unit
    elsif current_unit.organization_moderator?
      organization_moderator_role
      updation_unit
    elsif current_unit.departament_admin?
      departament_admin_role
      updation_unit
    elsif current_unit.departament_moderator?
      departament_moderator_role
      updation_unit
    elsif current_unit.units_admin?
      units_admin_role
      updation_unit
    else
        redirect_to organization_departament_units_path(organization, departament, unit)
    end
  end

  def destroy
    def deletion_unit
      if unit.destroy
        redirect_to organization_departament_units_path(organization, departament.id)
      end
    end
    if current_unit.global_admin?
      global_admin_role
      deletion_unit
    elsif current_unit.global_moderator?
      global_moderator_role
      deletion_unit
    elsif current_unit.organization_admin?
      organization_admin_role
      deletion_unit
    elsif current_unit.departament_admin?
      departament_admin_role
      deletion_unit
    else
      redirect_to organization_departament_units_path(organization, departament)
    end
  end

  def new_password
    if current_unit.id != unit.id
      redirect_to organization_departament_units_path(organization, departament)
    end
  end

  def units_self_admin
    if current_unit.id != unit.id
      redirect_to organization_departament_units_path(organization, departament)
    end
  end

  private
  def unit_params
    params.require(:unit).permit(:full_name, :belong_to_departament, :post, :email, :password, :password_confirmation, :secondary_email, :primary_phone_number, :secondary_phone_number, :short_phone_nunber, :fax, :home_phone_number, :web_page, :start_work, :finish_work, :working_days, :birthday, :login, :password, :characteristic, :show_hide_for_units, :show_hide_for_visitors, :role, :unitphoto)
  end

  def units
    @units ||= departament.units
  end
  helper_method :units

  def unit
    @unit ||= departament.units.find(params[:id])
  end
  helper_method :unit

  def new_unit
    @unit = Unit.new
  end

  def create_unit
    @unit = Unit.new(unit_params)
    @unit.organization = organization
    @unit.departament = departament
    if @unit.save and unit_signed_in?
      redirect_to organization_departament_units_path(organization, departament.id)
    else
      redirect_to new_unit_session_path()
    end
  end
end