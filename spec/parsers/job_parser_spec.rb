require 'parsers/job'
require 'parsers/job_parser'

describe JobParser do
  let(:empty_job_sequence) { "" }
  let(:single_job_sequence) { ' a => ' }
  let(:multiple_job_sequence_without_dependencies) { 'a =>
                                                      b =>
                                                      c =>  ' }
  let(:multiple_job_sequence_with_dependencies) { ' a =>
                                                    b => c
                                                    c =>  ' }

  let(:multiple_job_sequence_ordered_with_dependencies) { ' a =>
                                                            b => c
                                                            c => f
                                                            d => a
                                                            e => b
                                                            f =>   ' }

  let(:self_dependency_job_sequence) { ' a =>
                                       b =>
                                       c => c ' }

  let(:circular_dependency_job_sequence) { ' a =>
                                           b => c
                                           c => f
                                           d => a
                                           e =>
                                           f => b ' }

  it "should return a empty sequence given no jobs have been passed on" do
    expect(JobParser.sort_jobs(empty_job_sequence)).to eq ""
  end

  it "should return a single job given single job is passed" do
    expect(JobParser.sort_jobs(single_job_sequence)).to eq "a"
  end

  it "should return a multiple jobs in no-significant order given there are no dependencies" do
    result = JobParser.sort_jobs(multiple_job_sequence_without_dependencies)
    %w{a b c}.each { |letter_job| expect(result).to include(letter_job) }
  end

  it "should return multiple jobs in a significant order given dependencies exist" do
    result = JobParser.sort_jobs(multiple_job_sequence_with_dependencies)
    %w{a b c}.each { |letter_job| expect(result).to include(letter_job) }

    expect(result.index("c")).to be < result.index("b")
  end

  it "should return multiple jobs in a significant order given that there are multiple dependencies" do
    result = JobParser.sort_jobs(multiple_job_sequence_ordered_with_dependencies)

    %w{a b c d e f}.each { |letter_job| expect(result).to include(letter_job) }

    expect(result.index("f")).to be < result.index("c")
    expect(result.index("c")).to be < result.index("b")
    expect(result.index("b")).to be < result.index("e")
    expect(result.index("a")).to be < result.index("d")
  end

  it "should raise an error if a job depends on itself" do
    expect { JobParser.sort_jobs(self_dependency_job_sequence) }.to raise_error(ArgumentError) { |error|
      expect(error.message).to eq "Jobs can't depend on themselves"
    }
  end

  it "should raise an error if a circular dependency is added" do
    expect { JobParser.sort_jobs(circular_dependency_job_sequence) }.to raise_error(ArgumentError) { |error|
      expect(error.message).to eq "Jobs can't have circular dependencies"
    }
  end
end