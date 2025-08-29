r.db('stf').table('users').insert({
  email: 'admindevicefarm@gmail.com',
  name: 'admin',
  privilege: 'admin',
  group: 'admin-group-' + Math.random().toString(36).substr(2, 15),
  ip: '127.0.0.1',        
  forwards: [],                 
  groups: {
    subscribed: ['*'],           
    lock: false,              
    quotas: {
      allocated: { number: 999, duration: 86400000 },
      consumed: { number: 0, duration: 0 },
      defaultGroupsDuration: 86400000,
      defaultGroupsNumber: 999,
      defaultGroupsRepetitions: 0,
      repetitions: 0
    }
  },
  settings: {},
  lastLoggedInAt: r.now(),
  createdAt: r.now()
})             