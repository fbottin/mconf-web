# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AdmissionsController < ApplicationController
  before_filter :space!
  # TODO: permissions
  #authorization_filter [ :create, :performance ], :space

  def index
    respond_to do |format|
      format.html
    end
  end
end
