# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PostsController < ApplicationController
  # Include basic Resource methods
  # See documentation: ActionController::StationResources
  include ActionController::StationResources
  include SpamControllerModule

  layout "spaces_show"

  # Posts needs a Space. It will respond 404 if no space if found
  before_filter :space!
  before_filter :webconf_room!
  before_filter :post, :except => [ :index, :new, :create]

  load_and_authorize_resource :space
  load_and_authorize_resource :through => :space

  def index
    # AtomPub feeds are ordered by updated_at
    if request.format == Mime::ATOM
      params[:order], params[:direction] = "updated_at", "DESC"
    end

    posts

    respond_to do |format|
      format.html
      format.atom
      format.xml { render :xml => @posts }
    end
  end

  # Show this Entry
  #   GET /posts/:id
  def show
    if params[:last_page]
      post_comments(post, {:last => true})
    else
      post_comments(post)
    end

    respond_to do |format|
      format.html {
        # FIXME: this is wrong, VIEW code should go to app/views or app/helpers
        if request.xhr?
          if params[:edit]

            params[:form]='attachments'
            render :partial => "edit_post", :locals => { :post => post }
          else
            render :partial => "new_post", :locals => { :p_id=> @post.id, :id => "reply-form"}
          end
        end
      }
      format.xml { render :xml => @post.to_xml }
      format.json { render :json => @post.to_json }
    end
  end

  def reply_post
    @post_id = params[:id]
    respond_to do |format|
      format.html{
        render :partial => "reply_post"
      }
    end
  end

  # Renders form for editing this Entry metadata
  #   GET /posts/:id/edit
  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit_post"
      }
    end
  end

  # create and update now in ActionController::StationResources

  # Delete this Entry
  #   DELETE /spaces/:id/posts/:id --> :method => delete
  #destroy de content of the post. Then its container(post) is destroyed automatic.
  def destroy
    @post.destroy
    respond_to do |format|
      if !@post.event.nil?
        flash[:notice] = t('post.deleted', :postname => @post.title)
        format.html {redirect_to space_event_path(@space, @post.event)}
      elsif @post.parent_id.nil?
        flash[:notice] = t('thread.deleted')
        format.html { redirect_to space_posts_path(@space) }
      else
        flash[:notice] = t('post.deleted', :postname => @post.title)
        format.html { redirect_to request.referer }
      end
      format.js
      format.xml { head :ok }
    end
  end

  private

  # DRY (used in index and create.js)
  def posts
    per_page = params[:extended] ? 6 : 15
    @posts ||= Post.roots.in(@space).not_events().find(:all,
                                                     :order => "updated_at DESC"
    ).paginate(:page => params[:page],
                                                              :per_page => per_page)

  end

  def post_comments(parent_post, options = {})
    total_posts = parent_post.children
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.to_f./(per_page).ceil
    page = nil if page == 0

    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end

  def after_create_with_success
    redirect_to(request.referer || space_posts_path(@space))
  end

  def after_create_with_errors
    # This should be in the view
    params[:form] = 'attachments' if @post.attachments.any?
    flash[:error] = @post.errors.to_xml
    posts
    render :index
    flash.delete([:error])
  end

  def after_update_with_success
    redirect_to(request.referer || space_posts_path(@space))
  end

  def after_update_with_errors
    # This should be in the view
    params[:form] = 'attachments' if @post.attachments.any?
    flash[:error] = @post.errors.to_xml
    posts
    render :index
    flash.delete([:error])
  end
end
