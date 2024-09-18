// Not needed, this would be done on the competition page
const UPDATE_COMPETITION_ACCESS_MUTATION = gql`
  mutation UpdateCompetitionAccess($input: UpdateCompetitionAccessInput!) {
    updateCompetitionAccess(input: $input) {
      competition {
        id
        staffMembers {
          id
          user {
            id
          }
          roles
        }
      }
    }
  }
`;
// Will need new API Endpoint
const CLEAR_ROUND_MUTATION = gql`
  mutation ClearRound($input: ClearRoundInput!) {
    clearRound(input: $input) {
      round {
        id
        open
      }
    }
  }
`;
// Will need API Endpoint
const OPEN_ROUND_MUTATION = gql`
  mutation OpenRound($input: OpenRoundInput!) {
    openRound(input: $input) {
      round {
        id
        open
      }
    }
  }
`;
// Not needed anymore due to no synchronization
const SYNCHRONIZE_MUTATION = gql`
  mutation Synchronize($input: SynchronizeCompetitionInput!) {
    synchronizeCompetition(input: $input) {
      competition {
        id
        synchronizedAt
      }
    }
  }
`;
// Needs new Table
const ADMIN_ROUND_RESULT_FRAGMENT = gql`
  fragment adminRoundResult on Result {
    ranking
    advancing
    advancingQuestionable
    attempts {
      result
    }
    best
    average
    person {
      id
      registrantId
      name
      wcaId
    }
    singleRecordTag
    averageRecordTag
  }
`;
// Mh.. I think we can just change the Events in the Registration service
const ADD_PERSON_TO_ROUND_MUTATION = gql`
  mutation AddPersonToRound($input: AddPersonToRoundInput!) {
    addPersonToRound(input: $input) {
      round {
        id
        results {
          id
          ...adminRoundResult
        }
      }
    }
  }
  ${ADMIN_ROUND_RESULT_FRAGMENT}
`;
// Needs new API Endpoint
const ENTER_RESULTS = gql`
  mutation EnterResults($input: EnterResultsInput!) {
    enterResults(input: $input) {
      round {
        id
        number
        results {
          id
          ...adminRoundResult
        }
      }
    }
  }
  ${ADMIN_ROUND_RESULT_FRAGMENT}
`;
// Mh.. I think we can just change the Events in the Registration service
const REMOVE_PERSON_FROM_ROUND_MUTATION = gql`
  mutation RemovePersonFromRound($input: RemovePersonFromRoundInput!) {
    removePersonFromRound(input: $input) {
      round {
        id
        results {
          id
          ...adminRoundResult
        }
      }
    }
  }
  ${ADMIN_ROUND_RESULT_FRAGMENT}
`;
// Mh.. I think we can just change the Events in the Registration service
const REMOVE_NO_SHOWS_FROM_ROUND_MUTATION = gql`
  mutation RemoveNoShowsFromRound($input: RemoveNoShowsFromRoundInput!) {
    removeNoShowsFromRound(input: $input) {
      round {
        id
        results {
          id
          ...adminRoundResult
        }
      }
    }
  }
  ${ADMIN_ROUND_RESULT_FRAGMENT}
`;
// Not needed anymore due to no endpoints
const IMPORT_COMPETITION_MUTATION = gql`
  mutation ImportCompetition($input: ImportCompetitionInput!) {
    importCompetition(input: $input) {
      competition {
        id
      }
    }
  }
`;
// Needs new API Endpoint
const ENTER_RESULT_ATTEMPTS = gql`
  mutation EnterResults($input: EnterResultsInput!) {
    enterResults(input: $input) {
      round {
        id
        results {
          id
          attempts {
            result
          }
        }
      }
    }
  }
`;
// Not needed anymore due to integration with the main website
const GENERATE_ONE_TIME_CODE = gql`
  mutation GenerateOneTimeCode {
    generateOneTimeCode {
      oneTimeCode {
        id
        code
        expiresAt
        insertedAt
      }
    }
  }
`;
// Not needed anymore due to integration with the main website
const GENERATE_SCORETAKING_TOKEN = gql`
  mutation GenerateScoretakingToken($input: GenerateScoretakingTokenInput!) {
    generateScoretakingToken(input: $input) {
      token
    }
  }
`;
// Not needed anymore due to integration with the main website
const DELETE_SCORETAKING_TOKEN_MUTATION = gql`
  mutation DeleteScoretakingToken($input: DeleteScoretakingTokenInput!) {
    deleteScoretakingToken(input: $input) {
      scoretakingToken {
        id
      }
    }
  }
`;
