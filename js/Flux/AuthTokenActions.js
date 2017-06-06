/**
 * Copyright 2015-present 650 Industries. All rights reserved.
 *
 * @flow
 * @providesModule AuthTokenActions
 */

import Analytics from '../Api/Analytics';
import LocalStorage from '../Storage/LocalStorage';
import ApolloClient from '../Api/ApolloClient';

import { action } from 'Flux';

let AuthTokenActions = {
  signIn(tokens) {
    ApolloClient.resetStore();
    return AuthTokenActions.setAuthTokens(tokens);
  },

  @action setAuthTokens(tokens) {
    LocalStorage.saveAuthTokensAsync(tokens);
    return tokens;
  },

  @action updateIdToken(idToken) {
    LocalStorage.updateIdTokenAsync(idToken);
    return { idToken };
  },

  @action signOut() {
    LocalStorage.removeAuthTokensAsync();
    LocalStorage.clearHistoryAsync();

    // TODO(brent): add username or email to log out action
    Analytics.track(Analytics.events.USER_LOGGED_OUT);
    ApolloClient.resetStore();
    return null;
  },
};

export default AuthTokenActions;
