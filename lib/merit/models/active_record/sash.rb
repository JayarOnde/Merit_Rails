class Sash < ActiveRecord::Base
  has_many :badges_sashes, :dependent => :destroy
  has_many :scores, :dependent => :destroy, :class_name => 'Merit::Score'

  def badges
    badge_ids.collect { |b_id| Badge.find(b_id) }
  end

  def badge_ids
    badges_sashes.map(&:badge_id)
  end

  def add_badge(badge_id)
    bs = BadgesSash.new
    bs.badge_id = badge_id
    self.badges_sashes << bs
  end

  def rm_badge(badge_id)
    badges_sashes.find_by_badge_id(badge_id).try(:destroy)
  end

  def points(category = 'default')
    scores.where(:category => category).first.points
  end
end
