# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

FactoryGirl.define do
  factory :private_message do |m|
    m.sequence(:title) { |n| "Message #{n}" }
    m.sequence(:body) { |n| "Message body #{n}" }
    m.checked { false }
    m.deleted_by_sender { false }
    m.deleted_by_receiver { false }
  end
end
