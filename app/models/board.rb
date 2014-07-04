class Board < ActiveRecord::Base
  after_create :add_sample_lists

  validates :title, presence: true

  has_many :lists, -> { order(position: :asc) }

  def add_list!(params)
    lists.create(params)
  end

  private

  def add_sample_lists
    add_list!(
      title: I18n.t('lists.list.todo'),
      position: 0
    )

    add_list!(
      title: I18n.t('lists.list.doing'),
      position: 1
    )

    add_list!(
      title: I18n.t('lists.list.review'),
      position: 2
    )
  end
end