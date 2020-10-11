require 'rails_helper'

RSpec.describe "StaticPages", type: :system do
  describe "トップページ" do
    context "ページ全体" do
      before do
        visit root_path
      end

      it "トラベルログの文字列が存在することを確認" do
        expect(page).to have_content 'トラベルログ'
      end

      it "正しいタイトルが表示されることを確認" do
        expect(page).to have_title full_title
      end
    end
  end

  describe "ヘルプページ" do
    before do
      visit about_path
    end

    it "トラベルログとは？の文字列が存在することを確認" do
      expect(page).to have_content 'トラベルログとは？'
    end

    it "正しいタイトルが表示されることを確認" do
      expect(page).to have_title full_title('トラベルログとは？')
    end
  end

  describe "利用規約ページ" do
    before do
      visit use_of_terms_path
    end

    it "利用規約の文字列が存在することを確認" do
      expect(page).to have_content '利用規約'
    end

    it "正しいタイトルが表示されることを確認" do
      expect(page).to have_title full_title('利用規約')
    end
  end
end