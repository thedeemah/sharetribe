class Admin::GettingStartedGuideController < ApplicationController

  before_filter :ensure_is_admin

  rescue_from ReactOnRails::PrerenderError do |err|
    Rails.logger.error(err.message)
    Rails.logger.error(err.backtrace.join("\n"))
    redirect_to root_path, flash: { error: "Error prerendering in react_on_rails. See server logs." }
  end

  def index
    render locals: { props: data }
  end

  private

  def data
    path_parts = request.env['PATH_INFO'].split("/getting_started_guide")
    has_sub_path = (path_parts.count == 2 && path_parts[1] != "/")
    sub_path = has_sub_path ? path_parts[1] : "";

    onboarding_status = Admin::OnboardingWizard.new(@current_community.id).setup_status
    links_to_rails_routes = {
      slogan_and_description: {
        link: edit_details_admin_community_path(@current_community),
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      cover_photo: {
        link: edit_look_and_feel_admin_community_path(@current_community),
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      filter: {
        link: admin_custom_fields_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      paypal: {
        link: admin_paypal_preferences_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      listing: {
        link: new_listing_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      },
      invitation: {
        link: new_invitation_path,
        infoImage: view_context.image_path('onboardingImagePlaceholder.jpg')
      }
    }

    sorted_steps = OnboardingViewUtils.sorted_steps(onboarding_status)
      .map { |step| step.merge(links_to_rails_routes[step[:step]])}
      .inject({}) { |r, i| r[i[:step]] = i.except(:step); r }

    # This is the props used by the React component.
    { onboardingGuidePage: {
        path: sub_path,
        onboarding_data: sorted_steps,
        name: PersonViewUtils.person_display_name(@current_user, @current_community),
        translations: I18n.t('admin.onboarding.guide')
      }
    }
  end
end
