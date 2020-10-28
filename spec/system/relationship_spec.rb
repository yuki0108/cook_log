require 'rails_helper'

RSpec.describe "Relationships", type: :system do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }
  let!(:dish) { create(:dish, user: user) }
  let!(:dish2) { create(:dish, user: user2) }
  let!(:dish3) { create(:dish, user: user3) }

  describe "フォロー中(following一覧)ページ" do
    before do
      create(:relationship, follower_id: user.id, followed_id: user2.id)
      create(:relationship, follower_id: user.id, followed_id: user3.id)
      login_for_system(user)
      visit following_user_path(user)
    end

    context "ページレイアウト" do
      it "「フォロー中」の文字列が存在すること" do
        expect(page).to have_content 'フォロー中'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('フォロー中')
      end

      it "ユーザー情報が表示されていること" do
        expect(page).to have_content user.name
        expect(page).to have_link "プロフィール", href: user_path(user)
        expect(page).to have_content "料理#{user.dishes.count}件"
        expect(page).to have_link "#{user.following.count}人をフォロー", href: following_user_path(user)
        expect(page).to have_link "#{user.followers.count}人のフォロワー", href: followers_user_path(user)
      end

      it "フォロー中のユーザーが表示されていること" do
        within find('.users') do
          expect(page).to have_css 'li', count: user.following.count
          user.following.each do |u|
            expect(page).to have_link u.name, href: user_path(u)
          end
        end
      end
    end
  end

  describe "フォロワー(followers一覧)ページ" do
    before do
      create(:relationship, follower_id: user2.id, followed_id: user.id)
      create(:relationship, follower_id: user3.id, followed_id: user.id)
      create(:relationship, follower_id: user4.id, followed_id: user.id)
      login_for_system(user)
      visit followers_user_path(user)
    end

    context "ページレイアウト" do
      it "「フォロワー」の文字列が存在すること" do
        expect(page).to have_content 'フォロワー'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('フォロワー')
      end

      it "ユーザー情報が表示されていること" do
        expect(page).to have_content user.name
        expect(page).to have_link "プロフィール", href: user_path(user)
        expect(page).to have_content "料理#{user.dishes.count}件"
        expect(page).to have_link "#{user.following.count}人をフォロー", href: following_user_path(user)
        expect(page).to have_link "#{user.followers.count}人のフォロワー", href: followers_user_path(user)
      end

      it "フォロワーが表示されていること" do
        within find('.users') do
          expect(page).to have_css 'li', count: user.followers.count
          user.followers.each do |u|
            expect(page).to have_link u.name, href: user_path(u)
          end
        end
      end
    end
  end

  describe "フィード" do
    before do
      create(:relationship, follower_id: user.id, followed_id: user2.id)
      login_for_system(user)
    end

    it "フィードに自分の投稿が含まれていること" do
      expect(user.feed).to include dish
    end

    it "フィードにフォロー中ユーザーの投稿が含まれていること" do
      expect(user.feed).to include dish2
    end

    it "フィードにフォローしていないユーザーの投稿が含まれていないこと" do
      expect(user.feed).not_to include dish3
    end
  end
end
