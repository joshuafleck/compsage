namespace :release do
  task :freeze do
    date = Time.now.strftime("%Y-%m-%d")
    puts "Creating branch release-#{date} based on current branch"
    `git push origin origin:refs/heads/release-#{date}`
    `git fetch`
    Rake::Task['release:track'].invoke
  end

  task :track do
    branch = latest_release_branch
    `git branch --track #{local_branch_of(branch)} #{branch}`
    puts "Now tracking #{branch}"
  end

  task :checkout do
    branch = local_branch_of(latest_release_branch)
    existing_branch = `git branch | grep #{branch}`
    if existing_branch == '' then
      Rake::Task['release:track'].invoke
    end
    `git checkout #{branch}`

  end

  def latest_release_branch
    `git fetch`
    `git branch -r | grep 'origin/release-' | awk '{ print $1 }' | sort -fr | head -n1`.chomp
  end

  def local_branch_of(branch)
    branch.sub('origin/', '')
  end
end
