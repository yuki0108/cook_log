require 'rails_helper'

RSpec.describe "Dishes", type: :system do
  let!(:user) { create(:user) }
  let!(:dish) { create(:dish, user: user) }
  let!(:dish) { create(:dish, :picture, user: user) }
  let!(:log) { create(:log, dish: dish) }

  describe "料理登録ページ" do
    before do
      login_for_system(user)
      visit new_dish_path
    end

    context "ページレイアウト" do
      it "「料理登録」の文字列が存在すること" do
        expect(page).to have_content '料理登録'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('料理登録')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '料理名'
        expect(page).to have_content '説明'
        expect(page).to have_content 'コツ・ポイント'
        expect(page).to have_content '作り方参照用URL'
        expect(page).to have_content '所要時間 [分]'
        expect(page).to have_content '人気度 [1~5]'
        expect(page).to have_content 'クックメモ'
      end
    end

    context "料理登録処理" do
      it "有効な情報で料理登録を行うと料理登録成功のフラッシュが表示されること" do
        fill_in "料理名", with: "イカの塩焼き"
        fill_in "説明", with: "冬に食べたくなる、身体が温まる料理です"
        fill_in "分量", with: 1.5
        fill_in "コツ・ポイント", with: "ピリッと辛めに味付けするのがオススメ"
        fill_in "作り方参照用URL", with: "https://cookpad.com/recipe/2798655"
        fill_in "所要時間", with: 30
        fill_in "人気度", with: 5
        attach_file "dish[picture]", "#{Rails.root}/spec/fixtures/test_dish.jpg"
        click_button "登録する"
        expect(page).to have_content "料理が登録されました！"
      end

      it "画像無しで登録すると、デフォルト画像が割り当てられること" do
        fill_in "料理名", with: "イカの塩焼き"
        click_button "登録する"
        expect(page).to have_link(href: dish_path(Dish.first))
      end

      it "無効な情報で料理登録を行うと料理登録失敗のフラッシュが表示されること" do
        fill_in "料理名", with: ""
        fill_in "説明", with: "冬に食べたくなる、身体が温まる料理です"
        fill_in "分量", with: 1.5
        fill_in "コツ・ポイント", with: "ピリッと辛めに味付けするのがオススメ"
        fill_in "作り方参照用URL", with: "https://cookpad.com/recipe/2798655"
        fill_in "所要時間", with: 30
        fill_in "人気度", with: 5
        click_button "登録する"
        expect(page).to have_content "料理名を入力してください"
      end
    end
  end

  describe "料理編集ページ" do
    before do
      login_for_system(user)
      visit dish_path(dish)
      click_link "編集"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('料理情報の編集')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '料理名'
        expect(page).to have_content '説明'
        expect(page).to have_content '分量 [人分]'
        expect(page).to have_content 'コツ・ポイント'
        expect(page).to have_content '作り方参照用URL'
        expect(page).to have_content '所要時間 [分]'
        expect(page).to have_content '人気度 [1~5]'
      end
    end

    context "料理の更新処理" do
      it "有効な更新" do
        fill_in "料理名", with: "編集：イカの塩焼き"
        fill_in "説明", with: "編集：冬に食べたくなる、身体が温まる料理です"
        fill_in "分量", with: 3
        fill_in "コツ・ポイント", with: "編集：ピリッと辛めに味付けするのがオススメ"
        fill_in "作り方参照用URL", with: "henshu-https://cookpad.com/recipe/2798655"
        fill_in "所要時間", with: 60
        fill_in "人気度", with: 1
        attach_file "dish[picture]", "#{Rails.root}/spec/fixtures/test_dish2.jpg"
        click_button "更新する"
        expect(page).to have_content "料理情報が更新されました！"
        expect(dish.reload.name).to eq "編集：イカの塩焼き"
        expect(dish.reload.portion).to eq 3
        expect(dish.reload.tips).to eq "編集：ピリッと辛めに味付けするのがオススメ"
        expect(dish.reload.reference).to eq "henshu-https://cookpad.com/recipe/2798655"
        expect(dish.reload.required_time).to eq 60
        expect(dish.reload.popularity).to eq 1
        expect(dish.reload.picture.url).to include "test_dish2.jpg"
      end

      it "無効な更新" do
        fill_in "料理名", with: ""
        click_button "更新する"
        expect(page).to have_content '料理名を入力してください'
        expect(dish.reload.name).not_to eq ""
      end
    end
  end

  describe "料理詳細ページ" do
    context "ページレイアウト" do
      before do
        login_for_system(user)
        visit dish_path(dish)
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("#{dish.name}")
      end

      it "料理情報が表示されること" do
        expect(page).to have_content dish.name
        expect(page).to have_content dish.description
        expect(page).to have_content dish.portion
        expect(page).to have_content dish.tips
        expect(page).to have_content dish.reference
        expect(page).to have_content dish.required_time
        expect(page).to have_content dish.popularity
        expect(page).to have_link nil, href: dish_path(dish), class: 'dish-picture'
      end
    end

    context "料理の削除", js: true do
      it "削除成功のフラッシュが表示されること" do
        login_for_system(user)
        visit dish_path(dish)
        within find('.change-dish') do
          click_on '削除'
        end
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content '料理が削除されました'
      end
    end

    context "コメントの登録＆削除" do
      it "自分の料理に対するコメントの登録＆削除が正常に完了すること" do
        login_for_system(user)
        visit dish_path(dish)
        fill_in "comment_content", with: "今日の味付けは大成功"
        click_button "コメント"
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: '今日の味付けは大成功'
        end
        expect(page).to have_content "コメントを追加しました！"
        click_link "削除", href: comment_path(Comment.last)
        expect(page).not_to have_selector 'span', text: '今日の味付けは大成功'
        expect(page).to have_content "コメントを削除しました"
      end
    end

    context "ログ登録＆削除" do
      context "料理詳細ページから" do
        it "自分の料理に対するログ登録＆削除が正常に完了すること" do
          login_for_system(user)
          visit dish_path(dish)
          fill_in "log_content", with: "ログ投稿テスト"
          click_button "ログ追加"
          within find("#log-#{Log.first.id}") do
            expect(page).to have_selector 'span', text: "#{dish.logs.count}回目"
            expect(page).to have_selector 'span',
                                          text: %Q(#{Log.last.created_at.strftime("%Y/%m/%d(%a)")})
            expect(page).to have_selector 'span', text: 'ログ投稿テスト'
          end
          expect(page).to have_content "クックログを追加しました！"
          click_link "削除", href: log_path(Log.first)
          expect(page).not_to have_selector 'span', text: 'ログ投稿テスト'
          expect(page).to have_content "クックログを削除しました"
        end
      end

      context "トップページから" do
        it "自分の料理に対するログ登録が正常に完了すること" do
          login_for_system(user)
          visit root_path
          fill_in "log_content", with: "ログ投稿テスト"
          click_button "追加"
          expect(Log.first.content).to eq 'ログ投稿テスト'
          expect(page).to have_content "クックログを追加しました！"
        end
      end

      context "プロフィールページから" do
        it "自分の料理に対するログ登録が正常に完了すること" do
          login_for_system(user)
          visit user_path(user)
          fill_in "log_content", with: "ログ投稿テスト"
          click_button "追加"
          expect(Log.first.content).to eq 'ログ投稿テスト'
          expect(page).to have_content "クックログを追加しました！"
        end
      end

      context "リスト一覧ページから" do
        it "自分の料理に対するログ登録が正常に完了し、リストから料理が削除されること" do
          login_for_system(user)
          user.list(dish)
          visit lists_path
          expect(page).to have_content dish.name
          fill_in "log_content", with: "ログ投稿テスト"
          click_button "追加"
          expect(Log.first.content).to eq 'ログ投稿テスト'
          expect(page).to have_content "クックログを追加しました！"
          expect(List.count).to eq 0
        end
      end
    end

      context "検索機能" do
        context "ログインしている場合" do
          before do
            login_for_system(user)
            visit root_path
          end

          it "ログイン後の各ページに検索窓が表示されていること" do
            expect(page).to have_css 'form#dish_search'
            visit about_path
            expect(page).to have_css 'form#dish_search'
            visit use_of_terms_path
            expect(page).to have_css 'form#dish_search'
            visit users_path
            expect(page).to have_css 'form#dish_search'
            visit user_path(user)
            expect(page).to have_css 'form#dish_search'
            visit edit_user_path(user)
            expect(page).to have_css 'form#dish_search'
            visit following_user_path(user)
            expect(page).to have_css 'form#dish_search'
            visit followers_user_path(user)
            expect(page).to have_css 'form#dish_search'
            visit dishes_path
            expect(page).to have_css 'form#dish_search'
            visit dish_path(dish)
            expect(page).to have_css 'form#dish_search'
            visit new_dish_path
            expect(page).to have_css 'form#dish_search'
            visit edit_dish_path(dish)
            expect(page).to have_css 'form#dish_search'
          end

          it "フィードの中から検索ワードに該当する結果が表示されること" do
            create(:dish, name: 'かに玉', user: user)
            create(:dish, name: 'かに鍋', user: other_user)
            create(:dish, name: '野菜炒め', user: user)
            create(:dish, name: '野菜カレー', user: other_user)

            # 誰もフォローしない場合
            fill_in 'q_name_cont', with: 'かに'
            click_button '検索'
            expect(page).to have_css 'h3', text: "”かに”の検索結果：1件"
            within find('.dishes') do
              expect(page).to have_css 'li', count: 1
            end
            fill_in 'q_name_cont', with: '野菜'
            click_button '検索'
            expect(page).to have_css 'h3', text: "”野菜”の検索結果：1件"
            within find('.dishes') do
              expect(page).to have_css 'li', count: 1
            end

            # other_userをフォローする場合
            user.follow(other_user)
            fill_in 'q_name_cont', with: 'かに'
            click_button '検索'
            expect(page).to have_css 'h3', text: "”かに”の検索結果：2件"
            within find('.dishes') do
              expect(page).to have_css 'li', count: 2
            end
            fill_in 'q_name_cont', with: '野菜'
            click_button '検索'
            expect(page).to have_css 'h3', text: "”野菜”の検索結果：2件"
            within find('.dishes') do
              expect(page).to have_css 'li', count: 2
            end
          end

          it "検索ワードを入れずに検索ボタンを押した場合、料理一覧が表示されること" do
            fill_in 'q_name_cont', with: ''
            click_button '検索'
            expect(page).to have_css 'h3', text: "料理一覧"
            within find('.dishes') do
              expect(page).to have_css 'li', count: Dish.count
            end
          end
        end

        context "ログインしていない場合" do
          it "検索窓が表示されないこと" do
            visit root_path
            expect(page).not_to have_css 'form#dish_search'
          end
        end
      end
    end
  end
end
