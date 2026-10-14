require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:cookie_name) { AuthenticationConstants::AUTH_FIELD_ON_COOKIE }

  it 'connects and identifies the user with an active session cookie' do
    session = create(:session)
    cookies.signed[cookie_name] = session.id

    connect '/cable'

    expect(connection.current_user).to eq(session.user)
  end

  it 'rejects a connection without a cookie' do
    expect { connect '/cable' }.to have_rejected_connection
  end

  it 'rejects a connection with an expired session' do
    session = create(:session, :expired)
    cookies.signed[cookie_name] = session.id

    expect { connect '/cable' }.to have_rejected_connection
  end

  it 'rejects a connection with a revoked (deleted) session' do
    session = create(:session)
    cookies.signed[cookie_name] = session.id
    session.destroy

    expect { connect '/cable' }.to have_rejected_connection
  end

  it 'rejects an unsigned (forged) cookie' do
    cookies[cookie_name] = create(:session).id

    expect { connect '/cable' }.to have_rejected_connection
  end
end
