// New Table for live results needed
const RECORD_LIST_RECORD_FRAGMENT = gql`
  fragment records on Record {
    id
    tag
    type
    attemptResult
    result {
      id
      person {
        id
        name
        country {
          iso2
          name
        }
      }
      round {
        id
        competitionEvent {
          id
          event {
            id
            name
          }
          competition {
            id
          }
        }
      }
    }
  }
`;

// Already have a v0 query for this
const COMPETITIONS_QUERY = gql`
  query Competitions($from: Date!) {
    competitions(from: $from) {
      id
      name
      startDate
      endDate
      startTime
      endTime
      venues {
        id
        country {
          iso2
        }
      }
    }
    recentRecords {
      ...records
    }
  }
  ${RECORD_LIST_RECORD_FRAGMENT}
`;

// Probably easier to load in Ruby, not sure
const COMPETITION_QUERY = gql`
  query Competition($id: ID!) {
    competition(id: $id) {
      id
      shortName
      access {
        canManage
        canScoretake
      }
    }
  }
`;

// New Table for live results needed
const ADVANCEMENT_CANDIDATES_QUERY = gql`
  query AdvancementCandidates($roundId: ID!) {
    round(id: $roundId) {
      id
      advancementCandidates {
        qualifying {
          id
          name
          registrantId
        }
        revocable {
          id
          name
          registrantId
        }
      }
    }
  }
`;
// New Table for live results needed
const NEXT_QUALIFYING_QUERY = gql`
  query NextQualifying($roundId: ID!) {
    round(id: $roundId) {
      id
      nextQualifying {
        id
        name
      }
    }
  }
`;
// Probably easier to load in Ruby, not sure
const COMPETITION_QUERY = gql`
  query Competition($id: ID!) {
    competition(id: $id) {
      id
      staffMembers {
        id
        user {
          id
          name
        }
        roles
      }
    }
  }
`;
// Not needed, as importing won't exist
const IMPORTABLE_COMPETITIONS_QUERY = gql`
  query ImportableCompetitions {
    importableCompetitions {
      wcaId
      name
      startDate
      endDate
    }
  }
`;
// New Table for live results needed
// For world records we already have a v0 API
const ROUND_QUERY = gql`
  query Round($id: ID!) {
    round(id: $id) {
      id
      name
      competitionEvent {
        id
        event {
          id
          name
        }
      }
      format {
        id
        numberOfAttempts
      }
      timeLimit {
        centiseconds
        cumulativeRoundWcifIds
      }
      cutoff {
        numberOfAttempts
        attemptResult
      }
      results {
        id
        attempts {
          result
        }
        person {
          id
          name
          registrantId
        }
        enteredAt
      }
    }
    officialWorldRecords {
      event {
        id
      }
      type
      attemptResult
    }
  }
`;
// Not needed anymore due to no sync
const COMPETITION_QUERY = gql`
  query Competition($id: ID!) {
    competition(id: $id) {
      id
      wcaId
      synchronizedAt
    }
  }
`;
// Probably easier to load in Ruby, not sure
const COMPETITION_QUERY = gql`
  query Competition($id: ID!) {
    competition(id: $id) {
      id
      wcaId
      name
      competitionRecords {
        ...records
      }
      competitionEvents {
        id
        event {
          id
          name
        }
        rounds {
          id
          name
          active
          open
          number
        }
      }
      venues {
        id
        name
        country {
          iso2
          name
        }
        rooms {
          id
          name
          color
          activities {
            id
            activityCode
            name
            startTime
            endTime
          }
        }
      }
    }
  }
  ${RECORD_LIST_RECORD_FRAGMENT}
`;
// Probably easier to load in Ruby, not sure
const COMPETITION_QUERY = gql`
  query Competition($id: ID!) {
    competition(id: $id) {
      id
      shortName
      competitionEvents {
        id
        event {
          id
          name
        }
        rounds {
          id
          name
          label
          open
        }
      }
      access {
        canScoretake
      }
    }
  }
`;
// Already have a v0 API for this
const COMPETITION_EVENTS_QUERY = gql`
  query CompetitionEvents($id: ID!) {
    competition(id: $id) {
      id
      competitionEvents {
        id
        event {
          id
          name
        }
        rounds {
          id
          number
          name
          open
          finished
        }
      }
    }
  }
`;
// Needs new Table
// For World Records we already have a v0 API
const ROUND_QUERY = gql`
  query Round($id: ID!) {
    round(id: $id) {
      id
      name
      number
      competitionEvent {
        id
        event {
          id
          name
        }
        rounds {
          id
          number
          open
        }
      }
      format {
        id
        numberOfAttempts
        sortBy
      }
      timeLimit {
        centiseconds
        cumulativeRoundWcifIds
      }
      cutoff {
        numberOfAttempts
        attemptResult
      }
      results {
        id
        ...adminRoundResult
      }
    }
    officialWorldRecords {
      event {
        id
      }
      type
      attemptResult
    }
  }
  ${ADMIN_ROUND_RESULT_FRAGMENT}
`;

// Already have v0 API
const COMPETITIONS = gql`
  query Competitions($filter: String!) {
    competitions(filter: $filter, limit: 10) {
      id
      name
    }
  }
`;
// Already have v0 API
const COMPETITOR_QUERY = gql`
  query Competitor($id: ID!) {
    person(id: $id) {
      id
      name
      wcaId
      country {
        iso2
      }
      results {
        id
        ranking
        advancing
        advancingQuestionable
        attempts {
          result
        }
        best
        average
        singleRecordTag
        averageRecordTag
        round {
          id
          name
          number
          competitionEvent {
            id
            event {
              id
              name
              rank
            }
          }
          format {
            id
            numberOfAttempts
            sortBy
          }
        }
      }
    }
  }
`;
// Already have v0 API
const COMPETITORS_QUERY = gql`
  query Competition($competitionId: ID!) {
    competition(id: $competitionId) {
      id
      competitors {
        id
        name
        country {
          iso2
        }
      }
    }
  }
`;
// Passed on through Ruby
const CURRENT_USER_QUERY = gql`
  query CurrentUser {
    currentUser {
      id
      name
      avatar {
        thumbUrl
      }
    }
  }
`;
// Already have a v0 API
// For recent records we will need a new table
const COMPETITIONS_QUERY = gql`
  query Competitions($from: Date!) {
    competitions(from: $from) {
      id
      name
      startDate
      endDate
      startTime
      endTime
      venues {
        id
        country {
          iso2
        }
      }
    }
    recentRecords {
      ...records
    }
  }
  ${RECORD_LIST_RECORD_FRAGMENT}
`;
// Not needed anymore due to no import
const IMPORTABLE_COMPETITIONS_QUERY = gql`
  query ImportableCompetitions {
    importableCompetitions {
      wcaId
      name
      startDate
      endDate
    }
  }
`;
// Already have v0 API
const COMPETITIONS_QUERY = gql`
  query Competitions {
    currentUser {
      id
      staffMembers {
        id
        roles
        competition {
          id
          name
          startDate
          endDate
          venues {
            id
            country {
              iso2
            }
          }
        }
      }
      competitors {
        id
        competition {
          id
          name
          startDate
          endDate
          venues {
            id
            country {
              iso2
            }
          }
        }
      }
    }
  }
`;
// Will need new table for Live Results
const PODIUMS_QUERY = gql`
  query Podiums($competitionId: ID!) {
    competition(id: $competitionId) {
      id
      podiums {
        round {
          id
          finished
          competitionEvent {
            id
            event {
              id
              name
            }
          }
          format {
            id
            numberOfAttempts
            sortBy
          }
        }
        results {
          id
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
      }
    }
  }
`;
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
// Will need new Table
const ROUND_QUERY = gql`
  query Round($id: ID!) {
    round(id: $id) {
      id
      name
      finished
      active
      competitionEvent {
        id
        event {
          id
          name
        }
      }
      format {
        id
        numberOfAttempts
        sortBy
      }
      results {
        id
        ...roundResult
      }
    }
  }
  ${ROUND_RESULT_FRAGMENT}
`;
// Won't be needed anymore due to integrations into main site
const ACTIVE_SCORETAKING_TOKENS_QUERY = gql`
  query ActiveScoretakingTokensQuery {
    activeScoretakingTokens {
      id
      insertedAt
      competition {
        id
        name
      }
    }
  }
`;
// Already have a v0 API for this
const USERS = gql`
  query Users($filter: String!) {
    users(filter: $filter) {
      id
      name
    }
  }
`;
