# frozen_string_literal: true

namespace :results do
  desc "Migrates results from attempts"
  task migrate_attempts: [:environment] do
    Result.find_each do |result|
      value1 = result.value1
      Attempt.create(value: value1, attempt_number: 1, result_id: result.id)

      value2 = result.value2
      Attempt.create(value: value2, attempt_number: 2, result_id: result.id) unless value2.zero?
      next if value2.zero?

      value3 = result.value3
      Attempt.create(value: value3, attempt_number: 3, result_id: result.id) unless value3.zero?
      next if value3.zero?

      value4 = result.value4
      Attempt.create(value: value4, attempt_number: 4, result_id: result.id) unless value4.zero?
      next if value4.zero?

      value5 = result.value5
      Attempt.create(value: value5, attempt_number: 5, result_id: result.id) unless value5.zero?
    end
  end

  task :migrate_competition_results, [:competition_id] => [:environment] do |_, args|
    competition_id = args[:competition_id]

    abort "Competition id is required" if competition_id.blank?

    competition = Competition.find(competition_id)

    abort "Competition #{competition_id} not found" if competition.nil?

    competition.results.find_each do |result|
      value1 = result.value1
      Attempt.create(value: value1, attempt_number: 1, result_id: result.id)

      value2 = result.value2
      Attempt.create(value: value2, attempt_number: 2, result_id: result.id) unless value2.zero?
      next if value2.zero?

      value3 = result.value3
      Attempt.create(value: value3, attempt_number: 3, result_id: result.id) unless value3.zero?
      next if value3.zero?

      value4 = result.value4
      Attempt.create(value: value4, attempt_number: 4, result_id: result.id) unless value4.zero?
      next if value4.zero?

      value5 = result.value5
      Attempt.create(value: value5, attempt_number: 5, result_id: result.id) unless value5.zero?
    end
  end

  task :migrate_person_results, [:wca_id] => [:environment] do |_, args|
    wca_id = args[:wca_id]

    abort "WCA id is required" if wca_id.blank?

    person = Person.find_by(wca_id: wca_id)

    abort "Person #{wca_id} not found" if person.nil?

    person.results.find_each do |result|
      value1 = result.value1
      Attempt.create(value: value1, attempt_number: 1, result_id: result.id)

      value2 = result.value2
      Attempt.create(value: value2, attempt_number: 2, result_id: result.id) unless value2.zero?
      next if value2.zero?

      value3 = result.value3
      Attempt.create(value: value3, attempt_number: 3, result_id: result.id) unless value3.zero?
      next if value3.zero?

      value4 = result.value4
      Attempt.create(value: value4, attempt_number: 4, result_id: result.id) unless value4.zero?
      next if value4.zero?

      value5 = result.value5
      Attempt.create(value: value5, attempt_number: 5, result_id: result.id) unless value5.zero?
    end
  end
end
