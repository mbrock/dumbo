defmodule Dumbo.Rules.Behavioral do
  def sync(_opts) do
  end

  def now() do
    0
  end

  def timer(time) do
    {:timer, time}
  end

  def loop() do
    sync(wait: [:bathroom_occupied])
    sync(push: [{:set, :bathroom_light, :on}])
    loop()
  end

  def loop2() do
    sync(wait: [:bathroom_unoccupied])
    sync(push: [{:set, :bathroom_light, :off}])
    loop2()
  end

  def loop3() do
    sync(wait: [:bathroom_unoccupied])

    sync(
      wait: [{:time, now() + 5 * 60}, :bathroom_occupied],
      stop: [{:set, :bathroom_light, :off}]
    )

    loop3()
  end

  def loop4() do
    sync(wait: [:bathroom_occupied])

    sync(
      wait: [:bathroom_unoccupied],
      stop: [{:set, :bathroom_light, :off}]
    )

    loop4()
  end
end
