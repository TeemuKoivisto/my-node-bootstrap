import { dbClient } from '../../db/db-client'

import { IUser, ILoginCredentials } from '../../interfaces/user'

export const userService = {
  loginUser: async (credentials: ILoginCredentials) => {
    const result = await dbClient('loginUser', [credentials.email, credentials.password])
    return result
  },
  getUsers: async () => {
    const users = await dbClient('getUsers') as IUser[]
    return users
  }
}
