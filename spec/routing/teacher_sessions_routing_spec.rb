require 'spec_helper'

describe "Teacher Sessions Routing" do
  it "should route to teacher_sessions#new" do
    expect(get: '/teacher/sign_in').to route_to({ controller: 'teacher_sessions', action: 'new' })
  end

  it "should route to teacher_sessions#create" do
    expect(post: '/teacher_sessions').to route_to({ controller: 'teacher_sessions', action: 'create' })
  end

  it "should route to teacher_sessions#destroy" do
    expect(delete: '/teacher_sessions').to route_to({ controller: 'teacher_sessions', action: 'destroy' })
  end
end
