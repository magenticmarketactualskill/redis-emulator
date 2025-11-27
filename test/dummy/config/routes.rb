Rails.application.routes.draw do
  mount Redis::Emulator::Engine => "/redis-emulator"
end
