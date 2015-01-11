require 'feature_helper'

describe "HTML report" do
  # As a non-technical application product owner
  # I want license finder to generate an easy-to-understand HTML report
  # So that I can quickly review my application dependencies and licenses

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "shows basic dependency data" do
    gem_name = "a_gem"
    gem_group = "test"
    gem_attributes = {
      license:     "MIT",
      summary:     "gem is cool",
      description: "seriously",
      version:     "0.0.1",
      homepage:    "http://a_gem.github.com"
    }

    project = user.create_ruby_app
    project.create_and_depend_on gem_name, gem_attributes, { groups: [gem_group] }

    user.execute_command 'license_finder report --format html'

    user.view_html.in_dep(gem_name) do |section|
      expect(section.find("a[href='#{gem_attributes[:homepage]}']", text: gem_name)).to be
      expect(section).to have_content gem_attributes[:license]
      expect(section).to have_content gem_attributes[:summary]
      expect(section).to have_content gem_attributes[:description]
      expect(section).to have_content gem_attributes[:version]
      expect(section).to have_content gem_group
    end
  end

  specify "shows approval status of dependencies" do
    user.create_empty_project
    user.execute_command 'license_finder dependencies add gpl_dep GPL'
    user.execute_command 'license_finder dependencies add mit_dep MIT'
    user.execute_command 'license_finder whitelist add MIT'

    user.execute_command 'license_finder report --format html'

    html = user.view_html
    expect(html).to be_unapproved 'gpl_dep'
    expect(html).to be_approved 'mit_dep'

    expect(html).to have_content '1 GPL'
    action_items = html.find('.action-items')
    expect(action_items).to have_content '(GPL)'
    expect(action_items).not_to have_content 'MIT'
  end
end
