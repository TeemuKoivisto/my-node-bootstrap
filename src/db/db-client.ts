
import { IUserInternal } from '../interfaces/user'

const MOCK_DATA = {
  users: [
    {
      name: 'Admin',
      privileges: 'admin',
      email: 'admin@asdf.fi',
      password: 'qwertyui'
    },
    {
      name: 'Morty',
      privileges: 'user',
      email: 'morty@asdf.fi',
      password: 'asdfasdf'
    }
  ]
}

export const dbClient = async (query: string, params?: any[]) => {
  if (query === 'loginUser' && params && params.length === 2) {
    const foundUser = MOCK_DATA.users
      .find((user: IUserInternal) => user.email === params[0] && user.password === params[1])
    if (foundUser) {
      return Promise.resolve({
        name: foundUser.name,
        privileges: foundUser.privileges,
        email: foundUser.email
      })
    }
    return Promise.resolve(foundUser)
  }
  if (query === 'getUsers') {
    return Promise.resolve(MOCK_DATA.users)
  }
  return undefined
}
