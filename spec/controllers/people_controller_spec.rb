require 'rails_helper'

RSpec.describe PeopleController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_user!).and_return true
  end

  describe 'GET #index' do
    it 'assigns @people' do
      people = create_list(:person, 22)
      get :index
      expect(assigns(:people)).to eq(people)
    end

    it 'renders the :index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #new' do
    it 'renders the :new template' do
      get :new
      expect(response).to render_template('new')
    end
  end

  describe 'GET #edit' do
    before do
      @person = create :person
    end

    it 'assigns the requested person to @person' do
      get :edit, id: @person.id
      expect(assigns(:person)).to eq(@person)
    end

    it 'renders the :edit template' do
      get :edit, id: @person.id
      expect(response).to render_template('edit')
    end
  end

  describe 'GET #show' do
    before do
      @person = create :person
    end

    it 'assigns the requested person to @person' do
      get :show, id: @person.id
      expect(assigns(:person)).to eq(@person)
    end

    it 'renders the :show template' do
      get :show, id: @person.id
      expect(response).to render_template('show')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:image_file) { fixture_file_upload('files/300x300.gif', 'image/gif') }

      it 'saves the new person in the database' do
        expect do
          post :create, person: attributes_for(:person, image: image_file)
        end.to change(Person, :count).by(1)
      end

      it 'redirects to the person #show' do
        post :create, person: attributes_for(:person)
        expect(response).to redirect_to(assigns(:person))
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new person in the database' do
        expect do
          post :create, person: attributes_for(:invalid_person)
        end.to_not change(Person, :count)
      end

      it 're-renders the :new template' do
        post :create, person: attributes_for(:invalid_person)
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    before do
      @person = create :person
    end

    context 'with valid attributes' do
      let(:image_file) { fixture_file_upload('files/300x300.gif', 'image/gif') }

      it 'assigns the requested person to @person' do
        put :update, id: @person.id, person: attributes_for(:person, image: image_file)
        expect(assigns(:person)).to eq(@person)
      end

      it 'changes the @person attributes' do
        put :update, id: @person, person: attributes_for(:person, name: 'updated-name', image: image_file)
        @person.reload
        expect(@person.name).to eq 'updated-name'
      end

      it 'redirects to the updated person' do
        put :update, id: @person, person: attributes_for(:person, name: 'updated-name', image: image_file)
        expect(response).to redirect_to(@person)
      end
    end

    context 'with invalid attributes' do
      it 'assigns the requested person to @person' do
        put :update, id: @person.id, person: attributes_for(:invalid_person)
        expect(assigns(:person)).to eq(@person)
      end

      it 'does not change the @person attributes' do
        expect do
          put :update, id: @person, person: attributes_for(:invalid_person)
          @person.reload
        end.to_not change(@person, :name)
      end

      it 're-renders the :edit template' do
        put :update, id: @person, person: attributes_for(:invalid_person)
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      @person = create :person
    end

    it 'deletes the person' do
      expect { delete :destroy, id: @person.id }.to change(Person, :count).by(-1)
    end

    it 'redirects to person index' do
      delete :destroy, id: @person.id
      expect(response).to redirect_to(people_url)
    end
  end

  describe 'PUT #follow' do
    let(:user) { create :user }
    let(:person) { create :person }

    before do
      sign_in user
    end

    subject { put :follow, id: person.id }

    it 'current user follow person' do
      subject
      person.reload

      expect(person.followers).to include(user)
      expect(response).to redirect_to(person)
    end

    it 'current user try follow already followed person' do
      person.followers << user

      subject
      person.reload

      expect(controller.current_user).not_to receive(:save)
      expect(person.followers).to eq [user]
      expect(response).to redirect_to(person)
    end
  end

  describe 'PUT #unfollow' do
    let(:user) { create :user }
    let(:person) { create :person }

    before do
      sign_in user
    end

    subject { put :unfollow, id: person.id }

    it 'current user already unfollowed person' do
      person.followers << user

      expect(controller.current_user.followed_people).to receive(:delete)
      expect(controller.current_user).to receive(:save)

      subject
    end

    it 'current user unfollow person' do
      person.followers << user

      subject
      person.reload

      expect(person.followers).to eq []
      expect(response).to redirect_to(person)
    end
  end

  describe 'PUT #like' do
    let(:user) { create :user }
    let(:person) { create :person }

    before do
      sign_in user
    end

    subject { put :like, id: person.id }

    it 'current user like person' do
      subject
      person.reload

      expect(person.likers).to include(user)
      expect(response).to redirect_to(person)
    end

    it 'current user try like already liked person' do
      person.likers << user

      subject
      person.reload

      expect(controller.current_user).not_to receive(:save)
      expect(person.likers).to eq [user]
      expect(response).to redirect_to(person)
    end
  end

  describe 'PUT #unlike' do
    let(:user) { create :user }
    let(:person) { create :person }

    before do
      sign_in user
    end

    subject { put :unlike, id: person.id }

    it 'current user already liked person' do
      person.likers << user

      expect(controller.current_user.liked_people).to receive(:delete)
      expect(controller.current_user).to receive(:save)

      subject
    end

    it 'current user unlike person' do
      person.likers << user

      subject
      person.reload

      expect(person.likers).to eq []
      expect(response).to redirect_to(person)
    end
  end
end
