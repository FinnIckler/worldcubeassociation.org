const gql = () => {};

// Will need new Table
const ROUND_RESULT_FRAGMENT = gql`
  fragment roundResult on Result {
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
      name
      country {
        iso2
        name
      }
    }
    singleRecordTag
    averageRecordTag
  }
`;

// Can be replaced with Websocket updates
const ROUND_UPDATED_SUBSCRIPTION = gql`
  subscription RoundUpdated($id: ID!) {
    roundUpdated(id: $id) {
      id
      results {
        id
        ...roundResult
      }
    }
  }
  ${ROUND_RESULT_FRAGMENT}
`;
